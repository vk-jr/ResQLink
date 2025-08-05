import Layout from "@/components/Layout";
import SensorDashboard from "@/components/SensorDashboard";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

const SensorDataPage = () => {
  return (
    <Layout>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="space-y-6">
          <div className="relative">
            <div className="text-center space-y-4">
              <div className="relative mb-2">
                <h1 className="text-3xl font-bold text-primary text-center">
                  Sensor Data Dashboard
                </h1>
                <div className="absolute right-0 top-1/2 -translate-y-1/2">
                  <Select defaultValue="esp32-b">
                    <SelectTrigger className="w-[180px]">
                      <SelectValue placeholder="Select Location" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="esp32-b">ESP-32 B</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
              <p className="text-base text-muted-foreground max-w-2xl mx-auto">
                Real-time monitoring of environmental sensors measuring rainfall, ground vibration, 
                temperature, and soil moisture to detect landslide risk indicators.
              </p>
            </div>
          </div>
          
          <SensorDashboard />
        </div>
      </div>
    </Layout>
  );
};

export default SensorDataPage;