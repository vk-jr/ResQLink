import { useState } from "react";
import Layout from "@/components/Layout";
import MLOutputCard from "@/components/MLOutputCard";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import { 
  Brain, 
  TrendingUp, 
  AlertTriangle, 
  CheckCircle,
  Clock,
  BarChart3
} from "lucide-react";

const MLOutputPage = () => {
  const [recordLimit, setRecordLimit] = useState(20);
  
  return (
    <Layout>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="space-y-6">
          <div className="text-center space-y-4">
            <h1 className="text-3xl font-bold text-primary mb-2">
              Machine Learning Predictions
            </h1>
            <p className="text-base text-muted-foreground max-w-2xl mx-auto">
              Advanced AI-powered analysis combining sensor data, weather patterns, and historical 
              records to predict landslide risk with high accuracy.
            </p>
          </div>

          {/* Record Count Selector */}
          <div className="flex justify-end gap-2">
            <button
              onClick={() => setRecordLimit(10)}
              className={cn(
                "px-4 py-2 text-sm font-medium rounded-lg transition-colors",
                recordLimit === 10
                  ? "bg-primary text-primary-foreground"
                  : "bg-secondary hover:bg-secondary/80"
              )}
            >
              Last 10 Records
            </button>
            <button
              onClick={() => setRecordLimit(100)}
              className={cn(
                "px-4 py-2 text-sm font-medium rounded-lg transition-colors",
                recordLimit === 100
                  ? "bg-primary text-primary-foreground"
                  : "bg-secondary hover:bg-secondary/80"
              )}
            >
              Last 100 Records
            </button>
            <button
              onClick={() => setRecordLimit(1000)}
              className={cn(
                "px-4 py-2 text-sm font-medium rounded-lg transition-colors",
                recordLimit === 1000
                  ? "bg-primary text-primary-foreground"
                  : "bg-secondary hover:bg-secondary/80"
              )}
            >
              All Records
            </button>
          </div>

          {/* Current ML Prediction */}
          <MLOutputCard limit={recordLimit} />

          {/* ML Model Information */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <Card className="shadow-card">
              <CardHeader>
                <CardTitle className="flex items-center space-x-2">
                  <Brain className="h-5 w-5 text-primary" />
                  <span>Model Performance</span>
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div className="text-center p-4 bg-success/10 rounded-lg">
                    <CheckCircle className="h-8 w-8 text-success mx-auto mb-2" />
                    <div className="text-2xl font-bold text-success">87%</div>
                    <div className="text-sm text-muted-foreground">Accuracy</div>
                  </div>
                  
                  <div className="text-center p-4 bg-primary/10 rounded-lg">
                    <TrendingUp className="h-8 w-8 text-primary mx-auto mb-2" />
                    <div className="text-2xl font-bold text-primary">94%</div>
                    <div className="text-sm text-muted-foreground">Precision</div>
                  </div>
                </div>
                
                <div className="pt-4 border-t border-border">
                  <h4 className="font-semibold mb-2">Model Features</h4>
                  <div className="space-y-2">
                    <div className="flex items-center space-x-2">
                      <Badge variant="outline" className="text-xs">Real-time</Badge>
                      <span className="text-sm">Sensor data integration</span>
                    </div>
                    <div className="flex items-center space-x-2">
                      <Badge variant="outline" className="text-xs">Historical</Badge>
                      <span className="text-sm">Weather pattern analysis</span>
                    </div>
                    <div className="flex items-center space-x-2">
                      <Badge variant="outline" className="text-xs">Geospatial</Badge>
                      <span className="text-sm">Terrain risk assessment</span>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="shadow-card">
              <CardHeader>
                <CardTitle className="flex items-center space-x-2">
                  <Clock className="h-5 w-5 text-accent" />
                  <span>Prediction Timeline</span>
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-3">
                  <div className="flex items-center justify-between p-3 bg-destructive/10 rounded-lg border-l-4 border-destructive">
                    <div>
                      <div className="font-medium text-destructive">High Risk</div>
                      <div className="text-sm text-muted-foreground">0-6 hours</div>
                    </div>
                    <AlertTriangle className="h-5 w-5 text-destructive" />
                  </div>
                  
                  <div className="flex items-center justify-between p-3 bg-warning/10 rounded-lg border-l-4 border-warning">
                    <div>
                      <div className="font-medium text-warning">Medium Risk</div>
                      <div className="text-sm text-muted-foreground">6-24 hours</div>
                    </div>
                    <Clock className="h-5 w-5 text-warning" />
                  </div>
                  
                  <div className="flex items-center justify-between p-3 bg-success/10 rounded-lg border-l-4 border-success">
                    <div>
                      <div className="font-medium text-success">Low Risk</div>
                      <div className="text-sm text-muted-foreground">24+ hours</div>
                    </div>
                    <CheckCircle className="h-5 w-5 text-success" />
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Data Sources */}
          <Card className="shadow-card">
            <CardHeader>
              <CardTitle className="flex items-center space-x-2">
                <BarChart3 className="h-5 w-5 text-accent" />
                <span>Data Sources & Inputs</span>
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                <div className="text-center p-4 border bg-card rounded-lg hover:bg-accent/10 transition-colors">
                  <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-3">
                    <span className="text-primary font-bold">🌧️</span>
                  </div>
                  <h4 className="font-semibold mb-1">Weather Data</h4>
                  <p className="text-xs text-muted-foreground">Rainfall, humidity, temperature from 150+ sensors</p>
                </div>
                
                <div className="text-center p-4 border bg-card rounded-lg hover:bg-accent/10 transition-colors">
                  <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-3">
                    <span className="text-primary font-bold">🌍</span>
                  </div>
                  <h4 className="font-semibold mb-1">Ground Sensors</h4>
                  <p className="text-xs text-muted-foreground">Vibration, soil moisture, slope stability</p>
                </div>
                
                <div className="text-center p-4 border bg-card rounded-lg hover:bg-accent/10 transition-colors">
                  <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-3">
                    <span className="text-primary font-bold">🛰️</span>
                  </div>
                  <h4 className="font-semibold mb-1">Satellite Data</h4>
                  <p className="text-xs text-muted-foreground">Terrain analysis, vegetation, land use</p>
                </div>
                
                <div className="text-center p-4 border bg-card rounded-lg hover:bg-accent/10 transition-colors">
                  <div className="w-12 h-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-3">
                    <span className="text-primary font-bold">📊</span>
                  </div>
                  <h4 className="font-semibold mb-1">Historical Data</h4>
                  <p className="text-xs text-muted-foreground">Past events, seasonal patterns, geology</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </Layout>
  );
};

export default MLOutputPage;