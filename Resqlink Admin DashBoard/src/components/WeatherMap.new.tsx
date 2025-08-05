import { useEffect, useRef, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { useToast } from "@/hooks/use-toast";
import { 
  Globe, 
  Cloud, 
  Thermometer, 
  Droplets,
  Wind,
  RefreshCw
} from "lucide-react";

interface WeatherData {
  main: {
    temp: number;
    humidity: number;
    pressure: number;
  };
  weather: {
    main: string;
    description: string;
  }[];
  wind: {
    speed: number;
  };
  name: string;
}

const WeatherMap = () => {
  const mapRef = useRef<HTMLDivElement>(null);
  const [selectedLocation, setSelectedLocation] = useState<WeatherData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const apiKey = "36c51f6fbacf4b3498c31144252707";
  const { toast } = useToast();

  useEffect(() => {
    // Load Leaflet CSS
    const linkEl = document.createElement('link');
    linkEl.rel = 'stylesheet';
    linkEl.href = 'https://unpkg.com/leaflet@1.7.1/dist/leaflet.css';
    document.head.appendChild(linkEl);

    // Load Leaflet JS
    const script = document.createElement('script');
    script.src = 'https://unpkg.com/leaflet@1.7.1/dist/leaflet.js';
    script.async = true;
    document.body.appendChild(script);

    script.onload = () => {
      if (mapRef.current && window.L) {
        const map = L.map(mapRef.current).setView([20, 0], 2);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
          attribution: '© OpenStreetMap contributors'
        }).addTo(map);

        // Add weather overlay
        L.tileLayer(`https://tile.openweathermap.org/map/temp_new/{z}/{x}/{y}.png?appid=${apiKey}`, {
          opacity: 0.5
        }).addTo(map);

        // Handle map click
        map.on('click', async (e: any) => {
          const { lat, lng } = e.latlng;
          setIsLoading(true);
          
          try {
            const response = await fetch(
              `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lng}&appid=${apiKey}&units=metric`
            );
            if (!response.ok) throw new Error('Weather API request failed');
            const data = await response.json();
            setSelectedLocation(data);
            toast({
              title: "Location Selected",
              description: `Weather data loaded for ${data.name || 'selected location'}`,
            });
          } catch (error) {
            console.error('Error fetching weather data:', error);
            toast({
              title: "Weather Data Error",
              description: "Unable to fetch weather data for this location.",
              variant: "destructive",
            });
          } finally {
            setIsLoading(false);
          }
        });
      }
      setIsLoading(false);
    };

    return () => {
      if (document.body.contains(script)) {
        document.body.removeChild(script);
      }
    };
  }, []);

  return (
    <Card className="shadow-lg">
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <Globe className="h-5 w-5 text-primary" />
            <span>Interactive Weather Map</span>
          </div>
          <div className="flex items-center space-x-2">
            <Badge variant="outline" className="text-xs">
              Click on map to see weather details
            </Badge>
          </div>
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {isLoading && (
            <div className="absolute inset-0 bg-background/80 backdrop-blur-sm z-50 flex items-center justify-center">
              <div className="text-center space-y-4">
                <RefreshCw className="h-8 w-8 text-primary mx-auto animate-spin" />
                <p className="text-sm text-muted-foreground">Loading weather data...</p>
              </div>
            </div>
          )}
          
          <div 
            ref={mapRef} 
            className="aspect-[16/9] rounded-lg overflow-hidden border"
            style={{ minHeight: "400px" }}
          />
          
          {selectedLocation && (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
              <div className="p-4 bg-muted rounded-lg">
                <div className="flex items-center space-x-2">
                  <Cloud className="h-4 w-4 text-primary" />
                  <span className="text-sm font-medium">Weather</span>
                </div>
                <p className="mt-1 text-xl font-semibold">
                  {selectedLocation.weather[0].main}
                </p>
                <p className="text-xs text-muted-foreground">
                  {selectedLocation.weather[0].description}
                </p>
              </div>

              <div className="p-4 bg-muted rounded-lg">
                <div className="flex items-center space-x-2">
                  <Thermometer className="h-4 w-4 text-orange-500" />
                  <span className="text-sm font-medium">Temperature</span>
                </div>
                <p className="mt-1 text-xl font-semibold">
                  {selectedLocation.main.temp.toFixed(1)}°C
                </p>
                <p className="text-xs text-muted-foreground">
                  Humidity: {selectedLocation.main.humidity}%
                </p>
              </div>

              <div className="p-4 bg-muted rounded-lg">
                <div className="flex items-center space-x-2">
                  <Wind className="h-4 w-4 text-green-500" />
                  <span className="text-sm font-medium">Wind</span>
                </div>
                <p className="mt-1 text-xl font-semibold">
                  {selectedLocation.wind.speed} m/s
                </p>
                <p className="text-xs text-muted-foreground">
                  Pressure: {selectedLocation.main.pressure} hPa
                </p>
              </div>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
};

export default WeatherMap;
