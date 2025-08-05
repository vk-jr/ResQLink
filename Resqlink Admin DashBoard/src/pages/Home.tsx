import Layout from "@/components/Layout";
import MLOutputCard from "@/components/MLOutputCard";
import AlertSection from "@/components/AlertSection";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { 
  Shield, 
  Zap, 
  Globe, 
  Activity,
  TrendingUp,
  MapPin
} from "lucide-react";
import LandslideDocuments from "@/components/LandslideDocuments";
import EmergencySection from "@/components/EmergencySection";

const Home = () => {
  return (
    <Layout>
      <div className="space-y-8">
        {/* Hero Section */}
        <div className="relative flex items-center justify-center min-h-[20vh] bg-background/95">
          <div className="max-w-4xl mx-auto py-6">
            <div className="flex flex-col items-center text-center px-4 space-y-3">
              <h1 className="text-2xl md:text-3xl font-bold">
                <span className="text-primary">Landslide Early Warning</span>
                {" "}
                <span className="text-foreground">System</span>
              </h1>
              
              <p className="text-sm md:text-base text-muted-foreground max-w-2xl mx-auto">
                Advanced AI-powered monitoring system providing real-time landslide risk assessment 
                and emergency alerts to protect communities worldwide.
              </p>
            </div>
          </div>
        </div>

        {/* Main Content */}
        <div className="max-w-7xl mx-auto">
          <div className="space-y-8">
            {/* Current ML Status */}
            <div className="space-y-4">
              <h2 className="text-2xl font-bold flex items-center space-x-2">
                <MapPin className="h-6 w-6 text-primary" />
                <span>Current Risk Assessment</span>
              </h2>
              <MLOutputCard showHeader={false} showGraphs={false} />
            </div>

            {/* Emergency Alert Section */}
            <div className="space-y-4">
              <h2 className="text-2xl font-bold flex items-center space-x-2">
                <Shield className="h-6 w-6 text-destructive" />
                <span>Emergency Response</span>
              </h2>
              <AlertSection />
            </div>

            {/* Landslide Documents Section */}
            <div className="space-y-4">
              <LandslideDocuments />
            </div>

            {/* Emergency Section */}
            <div className="space-y-4">
              <h2 className="text-2xl font-bold flex items-center space-x-2">
                <Shield className="h-6 w-6 text-destructive" />
                <span>Emergency Center</span>
              </h2>
              <EmergencySection />
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default Home;