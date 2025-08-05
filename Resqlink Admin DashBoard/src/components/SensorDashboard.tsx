import { useEffect, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { 
  LineChart, 
  Line, 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  AreaChart,
  Area,
  PieChart,
  Pie,
  Cell,
  Legend
} from "recharts";
import { 
  Activity, 
  Droplets, 
  Thermometer, 
  Zap,
  RefreshCw,
  TrendingUp,
  AlertTriangle
} from "lucide-react";
import { supabase, type SensorData } from "@/lib/supabase";
import { useToast } from "@/hooks/use-toast";

const SensorDashboard = () => {
  const [sensorData, setSensorData] = useState<SensorData[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [lastUpdate, setLastUpdate] = useState<Date>(new Date());
  const [dataRange, setDataRange] = useState<'10' | '100' | 'all'>('10');
  const { toast } = useToast();

  const fetchSensorData = async () => {
    setIsLoading(true);
    try {
      console.log('Fetching data from Supabase...');
      let query = supabase
        .from('sensor_data')
        .select('*')
        .order('timestamp', { ascending: false });

      // Apply limit based on selected range
      if (dataRange !== 'all') {
        query = query.limit(parseInt(dataRange));
      }

      const { data: rawData, error } = await query;

      if (error) {
        console.error('Database error:', error);
        throw new Error(`Failed to fetch sensor data: ${error.message}`);
      }

      if (!rawData) {
        throw new Error('No data received from database');
      }

      // Validate and transform the data
      const validData = rawData.map(row => ({
        ...row,
        soil_moisture: row.soil_moisture || 0,
        pore_water_pressure: row.pore_water_pressure || 0,
        rainfall_24h_mm: row.rainfall_24h_mm || 0,
        rainfall_3h_mm: row.rainfall_3h_mm || 0,
        slope_degrees: row.slope_degrees || 0,
        soil_type: row.soil_type || 'Unknown',
        landslide_risk: row.landslide_risk || 'low'
      }));

      if (validData.length === 0) {
        toast({
          title: "No Data Found",
          description: "No sensor readings available in the database.",
          variant: "destructive",
        });
        return;
      }

      // Reverse the data to show oldest to newest
      setSensorData(validData.reverse());
      setLastUpdate(new Date());
      
      toast({
        title: "Sensor Data Updated",
        description: `Loaded ${validData.length} readings from the database.`,
      });
    } catch (error) {
      console.error('Error fetching sensor data:', error);
      if (error instanceof Error) {
        toast({
          title: "Data Fetch Error",
          description: error.message,
          variant: "destructive",
        });
      } else {
        toast({
          title: "Data Fetch Error",
          description: "Unable to load sensor data. Please check your connection.",
          variant: "destructive",
        });
      }
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    // Initial fetch
    fetchSensorData();

    // Set up real-time subscription with error handling
    const subscription = supabase
      .channel('sensor_updates')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'sensor_data'
        },
        async (payload) => {
          try {
            await fetchSensorData();
          } catch (error) {
            console.error('Error in real-time update:', error);
            toast({
              title: "Real-time Update Failed",
              description: "Unable to fetch latest sensor data. Will retry on next update.",
              variant: "destructive",
            });
          }
        }
      )
      .subscribe((status) => {
        if (status === 'SUBSCRIBED') {
          console.log('Successfully subscribed to real-time updates');
        } else {
          console.warn('Subscription status:', status);
        }
      });

    // Clean up subscription when component unmounts
    return () => {
      subscription.unsubscribe();
    };
  }, [dataRange]); // Added dataRange as dependency since it affects fetching

  const formatChartData = () => {
    return sensorData.map(item => ({
      time: new Date(item.timestamp).toLocaleTimeString('en-US', { 
        hour: '2-digit', 
        minute: '2-digit' 
      }),
      moisture: item.soil_moisture,
      pore_water_pressure: item.pore_water_pressure,
      rainfall_24h: item.rainfall_24h_mm,
      rainfall_3h: item.rainfall_3h_mm
    }));
  };

  const getAverageReading = (field: keyof SensorData) => {
    if (sensorData.length === 0) return 0;
    const values = sensorData.map(item => item[field] as number).filter(val => typeof val === 'number');
    return values.reduce((a, b) => a + b, 0) / values.length;
  };

  const getRiskLevel = () => {
    const latestReading = sensorData[sensorData.length - 1];
    if (!latestReading) return 'low';
    
    if (latestReading.landslide_risk.toLowerCase() === 'high') return 'high';
    if (latestReading.landslide_risk.toLowerCase() === 'medium') return 'medium';
    return 'low';
  };

  const getSoilTypeData = () => {
    // Count occurrences of each soil type
    const soilTypeCounts = sensorData.reduce((acc, item) => {
      if (item.soil_type) {
        acc[item.soil_type] = (acc[item.soil_type] || 0) + 1;
      }
      return acc;
    }, {} as Record<string, number>);

    // Convert to format needed for pie chart
    return Object.entries(soilTypeCounts).map(([type, count]) => ({
      name: type,
      value: count
    }));
  };

  const getLatestSlope = () => {
    const latestReading = sensorData[sensorData.length - 1];
    return latestReading?.slope_degrees || 0;
  };

  const SOIL_TYPE_COLORS = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEEAD'];

  const chartData = formatChartData();
  const riskLevel = getRiskLevel();

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {[...Array(4)].map((_, i) => (
            <Card key={i} className="shadow-card">
              <CardContent className="p-6">
                <div className="animate-pulse space-y-4">
                  <div className="flex items-center justify-between">
                    <div className="h-4 bg-muted rounded w-1/3"></div>
                    <div className="h-4 bg-muted rounded w-1/4"></div>
                  </div>
                  <div className="space-y-2">
                    <div className="h-8 bg-muted rounded"></div>
                    <div className="h-4 bg-muted rounded w-2/3"></div>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
        <Card className="shadow-card">
          <CardContent className="p-6">
            <div className="animate-pulse space-y-4">
              <div className="h-6 bg-muted rounded w-1/3"></div>
              <div className="h-[300px] bg-muted rounded"></div>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Status Overview */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Rainfall Card */}
        <Card className="shadow-card relative overflow-hidden">
          <CardContent className="pt-6">
            <div className="flex items-center justify-between space-x-2">
              <div className="flex items-center space-x-2">
                <Droplets className="h-4 w-4 text-blue-500" />
                <span className="text-sm font-medium">Rainfall</span>
              </div>
              <Badge variant="secondary" className="text-xs">24h Average</Badge>
            </div>
            <div className="mt-4">
              <div className="text-2xl font-bold mb-1">{getAverageReading('rainfall_24h_mm').toFixed(1)}mm</div>
              <div className="mt-2 flex items-center gap-2">
                <Badge variant="outline" className="text-xs">3h: {getAverageReading('rainfall_3h_mm').toFixed(1)}mm</Badge>
              </div>
              <div className="mt-2 h-2 bg-secondary rounded-full overflow-hidden">
                <div 
                  className="h-full bg-blue-500 transition-all" 
                  style={{ width: `${Math.min((getAverageReading('rainfall_24h_mm') / 100) * 100, 100)}%` }}
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Soil Moisture Card */}
        <Card className="shadow-card relative overflow-hidden">
          <CardContent className="pt-6">
            <div className="flex items-center justify-between space-x-2">
              <div className="flex items-center space-x-2">
                <Droplets className="h-4 w-4 text-emerald-500" />
                <span className="text-sm font-medium">Soil Moisture</span>
              </div>
              <Badge variant="secondary" className="text-xs">Ground Level</Badge>
            </div>
            <div className="mt-4">
              <div className="text-2xl font-bold mb-1">{getAverageReading('soil_moisture').toFixed(1)}%</div>
              <p className="text-sm text-muted-foreground">Saturation level</p>
              <div className="mt-2 h-2 bg-secondary rounded-full overflow-hidden">
                <div 
                  className="h-full bg-emerald-500 transition-all" 
                  style={{ width: `${Math.min(getAverageReading('predicted_soil_moisture'), 100)}%` }}
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Pore Water Pressure Card */}
        <Card className="shadow-card relative overflow-hidden">
          <CardContent className="pt-6">
            <div className="flex items-center justify-between space-x-2">
              <div className="flex items-center space-x-2">
                <TrendingUp className="h-4 w-4 text-violet-500" />
                <span className="text-sm font-medium">Pore Pressure</span>
              </div>
              <Badge variant="secondary" className="text-xs">Real-time</Badge>
            </div>
            <div className="mt-4">
              <div className="text-2xl font-bold mb-1">{getAverageReading('pore_water_pressure').toFixed(1)} kPa</div>
              <p className="text-sm text-muted-foreground">Ground water pressure</p>
              <div className="mt-2 flex items-center gap-2">
                <Badge variant="outline" className="text-xs">Monitoring Active</Badge>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Risk Level Card */}
        <Card className={cn(
          "shadow-card relative overflow-hidden",
          riskLevel === 'high' ? 'border-destructive bg-destructive/10' : 
          riskLevel === 'medium' ? 'border-yellow-500 bg-yellow-500/10' : 
          'border-green-500 bg-green-500/10'
        )}>
          <CardContent className="pt-6">
            <div className="flex items-center justify-between space-x-2">
              <div className="flex items-center space-x-2">
                <AlertTriangle className={cn(
                  "h-4 w-4",
                  riskLevel === 'high' ? 'text-destructive' : 
                  riskLevel === 'medium' ? 'text-yellow-500' : 
                  'text-green-500'
                )} />
                <span className="text-sm font-medium">Risk Level</span>
              </div>
              <Badge variant={riskLevel === 'high' ? 'destructive' : 'outline'} className="uppercase font-semibold">
                {riskLevel}
              </Badge>
            </div>
            <div className="mt-4">
              <p className="text-sm text-muted-foreground">Current assessment based on all sensor data</p>
              <div className="mt-2 flex items-center gap-2">
                <Badge variant="secondary" className="text-xs">Updated {lastUpdate.toLocaleTimeString()}</Badge>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Controls */}
      <Card className="shadow-card">
        <CardHeader>
          <CardTitle className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <div className="flex items-center">
                <img src="/resqlink-logo.png" alt="ResQLink Logo" className="h-10" />
                <div className="ml-2 font-semibold">ResQLink Admin</div>
              </div>
              <div className="flex items-center space-x-2">
                <span>Sensor Data Dashboard</span>
                <Badge variant="outline">Live</Badge>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <p className="text-sm text-muted-foreground">
                Last updated: {lastUpdate.toLocaleTimeString()}
              </p>
              <div className="flex items-center space-x-2">
                <Select
                  value={dataRange}
                  onValueChange={(value: '10' | '100' | 'all') => {
                    setDataRange(value);
                    fetchSensorData();
                  }}
                >
                  <SelectTrigger className="w-[180px]">
                    <SelectValue placeholder="Select range" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="10">Last 10 Records</SelectItem>
                    <SelectItem value="100">Last 100 Records</SelectItem>
                    <SelectItem value="all">All Records</SelectItem>
                  </SelectContent>
                </Select>
                <Button onClick={fetchSensorData} variant="outline" size="sm">
                  <RefreshCw className="h-4 w-4 mr-2" />
                  Refresh
                </Button>
              </div>
            </div>
          </CardTitle>
        </CardHeader>
      </Card>

      {/* Rainfall Chart */}
      <Card className="shadow-card">
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <TrendingUp className="h-5 w-5 text-primary" />
            <span>Rainfall Measurements</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="time" />
              <YAxis label={{ value: 'Rainfall (mm)', angle: -90, position: 'insideLeft' }} />
              <Tooltip />
              <Line 
                type="monotone" 
                dataKey="rainfall_24h" 
                stroke="#3b82f6" 
                strokeWidth={2}
                name="24h Rainfall (mm)"
              />
              <Line 
                type="monotone" 
                dataKey="rainfall_3h" 
                stroke="#22c55e" 
                strokeWidth={2}
                name="3h Rainfall (mm)"
              />
            </LineChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      {/* Soil Parameters */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card className="shadow-card">
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <Droplets className="h-5 w-5 text-blue-500" />
              <span>Soil Moisture</span>
            </CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <AreaChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="time" />
                <YAxis domain={[0, 100]} />
                <Tooltip />
                <Area 
                  type="monotone" 
                  dataKey="moisture" 
                  stroke="#06b6d4"
                  fill="#06b6d4"
                  fillOpacity={0.3}
                  name="Soil Moisture (%)"
                />
              </AreaChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card className="shadow-card">
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <Activity className="h-5 w-5 text-purple-500" />
              <span>Pore Water Pressure</span>
            </CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <AreaChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="time" />
                <YAxis />
                <Tooltip />
                <Area
                  type="monotone"
                  dataKey="pore_water_pressure"
                  stroke="#8b5cf6"
                  fill="#8b5cf6"
                  fillOpacity={0.3}
                  name="Pore Water Pressure (kPa)"
                />
              </AreaChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      {/* Slope and Soil Type Analysis */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Slope Card */}
        <Card className="shadow-card">
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <TrendingUp className="h-5 w-5 text-orange-500" />
              <span>Slope Analysis</span>
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex flex-col items-center justify-center p-6">
              <div className="text-4xl font-bold text-orange-500 mb-2">
                {getLatestSlope().toFixed(1)}°
              </div>
              <p className="text-sm text-muted-foreground mb-4">Current Slope Angle</p>
              <div className="w-full max-w-xs">
                <div className="h-4 bg-secondary rounded-full overflow-hidden">
                  <div 
                    className={cn(
                      "h-full transition-all",
                      getLatestSlope() > 45 ? "bg-destructive" :
                      getLatestSlope() > 30 ? "bg-yellow-500" :
                      "bg-green-500"
                    )}
                    style={{ width: `${Math.min((getLatestSlope() / 90) * 100, 100)}%` }}
                  />
                </div>
                <div className="mt-2 flex justify-between text-xs text-muted-foreground">
                  <span>Safe (0-30°)</span>
                  <span>Warning (30-45°)</span>
                  <span>Danger ({'>'}45°)</span>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Soil Type Distribution */}
        <Card className="shadow-card">
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <Droplets className="h-5 w-5 text-emerald-500" />
              <span>Soil Type Distribution</span>
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="w-full h-[250px]">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={getSoilTypeData()}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    outerRadius={80}
                    fill="#8884d8"
                    dataKey="value"
                    label={({ name, value, percent }) => 
                      `${name}: ${(percent * 100).toFixed(0)}%`
                    }
                  >
                    {getSoilTypeData().map((entry, index) => (
                      <Cell 
                        key={`cell-${index}`} 
                        fill={SOIL_TYPE_COLORS[index % SOIL_TYPE_COLORS.length]} 
                      />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default SensorDashboard;