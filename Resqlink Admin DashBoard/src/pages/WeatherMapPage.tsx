import Layout from "@/components/Layout";
import WeatherMap from "@/components/WeatherMap";

const WeatherMapPage = () => {
  return (
    <Layout>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="space-y-6">
          <div className="text-center space-y-4">
            <h1 className="text-3xl font-bold text-primary mb-2">
              Live Weather Map
            </h1>
            <p className="text-base text-muted-foreground max-w-2xl mx-auto">
              Real-time weather monitoring with temperature, humidity, and precipitation data 
              from around the world to enhance landslide risk assessment.
            </p>
          </div>
          
          <WeatherMap />
        </div>
      </div>
    </Layout>
  );
};

export default WeatherMapPage;