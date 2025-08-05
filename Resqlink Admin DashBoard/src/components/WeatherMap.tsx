// @ts-ignore
import { useEffect, useRef, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { useToast } from "@/hooks/use-toast";
import { 
  Globe, 
  Cloud, 
  Thermometer, 
  Wind,
  RefreshCw
} from "lucide-react";

const degToCompass = (num: number | undefined): string => {
    if (num === undefined) return '';
    const val = Math.floor((num / 22.5) + 0.5);
    const arr = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
    return arr[(val % 16)];
};

interface WeatherData {
  main: {
    temp: number;
    humidity: number;
    pressure: number;
    feels_like?: number;
  };
  weather: {
    main: string;
    description: string;
    icon: string;
  }[];
  wind: {
    speed: number;
    deg?: number;
    gust?: number;
  };
  visibility?: number;
  name: string;
}

declare global {
  interface Window {
    L: any;
  }
}

const WeatherMap = () => {
  const mapRef = useRef<HTMLDivElement>(null);
  const [selectedLocation, setSelectedLocation] = useState<WeatherData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const apiKey = "1635890035cbba097fd5c26c8ea672a1";  // Updated API key
  const { toast } = useToast();

  // Monitoring locations in Kerala and nearby areas
  const monitoredLocations = [
    { lat: 12.9716, lng: 77.5946, name: "Bangalore" },    // Karnataka
    { lat: 8.8932, lng: 76.6141, name: "Thiruvananthapuram" }, // South Kerala
    { lat: 17.3850, lng: 78.4867, name: "Hyderabad" },       // Telangana
  ];

  useEffect(() => {
    // Load Leaflet CSS with z-index fixes
    const style = document.createElement('style');
    style.textContent = `
      .leaflet-container { z-index: 1; }
      .leaflet-popup { z-index: 2; }
      .weather-widget {
        padding: 4px;
        font-size: 11px;
        background: rgba(255, 255, 255, 0.85);
        backdrop-filter: blur(8px);
      }
    `;
    document.head.appendChild(style);

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
        const map = window.L.map(mapRef.current, {
          zoomControl: true,
          scrollWheelZoom: true,
          doubleClickZoom: true,
          center: [12.2602, 76.2711],  // Kerala coordinates
          zoom: 6,
          minZoom: 4  // Prevent zooming out too far
        });

        window.L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
          attribution: '© OpenStreetMap contributors'
        }).addTo(map);

        // Add weather overlay layers
        const tempLayer = window.L.tileLayer(`https://tile.openweathermap.org/map/temp_new/{z}/{x}/{y}.png?appid=${apiKey}`, {
          opacity: 0.3
        }).addTo(map);

        const precipitationLayer = window.L.tileLayer(`https://tile.openweathermap.org/map/precipitation_new/{z}/{x}/{y}.png?appid=${apiKey}`, {
          opacity: 0.3
        });

        // Create layer control
        const baseMaps = {
          "OpenStreetMap": window.L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'),
        };
        
        const overlayMaps = {
          "Temperature": tempLayer,
          "Precipitation": precipitationLayer
        };

        window.L.control.layers(baseMaps, overlayMaps).addTo(map);

        // Add weather widgets for monitored locations
        monitoredLocations.forEach(async (location) => {
          try {
            const response = await fetch(
              `https://api.openweathermap.org/data/2.5/weather?lat=${location.lat}&lon=${location.lng}&appid=${apiKey}&units=metric`
            );
            if (!response.ok) throw new Error('Weather API request failed');
            const data = await response.json();
            
            const widget = window.L.popup({
              closeButton: false,
              autoClose: false,
              closeOnEscapeKey: false,
              closeOnClick: false,
              className: 'weather-widget',
              maxWidth: 200
            })
            .setLatLng([location.lat, location.lng])
            .setContent(`
              <div class="text-[10px] leading-tight">
                <div class="font-semibold text-[11px]">${location.name}</div>
                <div class="flex items-center gap-1.5 mt-0.5">
                  <span class="font-bold text-[13px]">${data.main.temp.toFixed(1)}°C</span>
                  <span class="text-gray-600 text-[10px]">${data.weather[0].main}</span>
                </div>
                <div class="flex items-center justify-between text-[9px] text-gray-500 mt-0.5">
                  <span>💧${data.main.humidity}%</span>
                  <span>💨${data.wind.speed}m/s</span>
                </div>
              </div>
            `)
            .addTo(map);
          } catch (error) {
            console.error(`Error fetching weather for ${location.name}:`, error);
          }
        });

        // Handle map click for detailed weather
        map.on('click', async (e: any) => {
          const { lat, lng } = e.latlng;
          setIsLoading(true);
          
          try {
            const response = await fetch(
              `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lng}&appid=${apiKey}&units=metric`
            );
            if (!response.ok) {
              const errorData = await response.json();
              throw new Error(errorData.message || 'Weather API request failed');
            }
            const data = await response.json();
            setSelectedLocation(data);
            console.log('Weather data fetched:', data);

            // Create a popup at the clicked location
            window.L.popup({ closeButton: true, autoClose: true })
              .setLatLng([lat, lng])
              .setContent(`
                <div class="p-3 bg-white/90 backdrop-blur-xl" style="width: 220px; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
                    <div class="flex items-center justify-between">
                        <span class="text-4xl font-light text-gray-800">${data.main.temp.toFixed(0)}°C</span>
                        <img src="http://openweathermap.org/img/wn/${data.weather[0].icon}@2x.png" alt="${data.weather[0].description}" class="w-12 h-12 -mr-2">
                    </div>
                    <div class="text-left -mt-2">
                        <div class="font-semibold text-gray-700 text-md">${data.weather[0].main}</div>
                        <div class="text-sm text-gray-500">${data.name}</div>
                    </div>
                    <div class="my-2 border-t border-gray-200/80"></div>
                    <div class="grid grid-cols-2 gap-x-4 gap-y-1 text-xs">
                        <div class="flex justify-between text-gray-600"><span>Feels like</span> <span class="font-semibold text-gray-800">${data.main.feels_like?.toFixed(0)}°C</span></div>
                        <div class="flex justify-between text-gray-600"><span>Humidity</span> <span class="font-semibold text-gray-800">${data.main.humidity}%</span></div>
                        <div class="flex justify-between text-gray-600"><span>Wind</span> <span class="font-semibold text-gray-800">${(data.wind.speed * 3.6).toFixed(0)} km/h ${degToCompass(data.wind.deg)}</span></div>
                        <div class="flex justify-between text-gray-600"><span>Visibility</span> <span class="font-semibold text-gray-800">${data.visibility ? (data.visibility / 1000).toFixed(0) : 'N/A'} km</span></div>
                        <div class="flex justify-between text-gray-600"><span>Pressure</span> <span class="font-semibold text-gray-800">${data.main.pressure} mb</span></div>
                    </div>
                </div>
              `)
              .openOn(map);

            toast({
              title: "Location Selected",
              description: `Weather data loaded for ${data.name || 'selected location'}`,
            });
          } catch (error: any) {
            console.error('Error fetching weather data:', error);
            toast({
              title: "Weather Data Error",
              description: error.message || "Unable to fetch weather data for this location.",
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
            className="aspect-[16/9] rounded-lg overflow-hidden border relative"
            style={{ minHeight: "400px", zIndex: 0 }}
          >
            <div className="absolute top-4 right-4 z-10 space-y-2">
              <Badge variant="outline" className="bg-background/80 backdrop-blur-sm">
                🔍 Zoom in/out for details
              </Badge>
              <Badge variant="outline" className="bg-background/80 backdrop-blur-sm">
                ⚡ Live weather updates
              </Badge>
            </div>
          </div>
          
          {selectedLocation && selectedLocation.weather && selectedLocation.weather[0] && (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
              <div className="p-6">
                <div className="flex items-center space-x-2 mb-3">
                  <Cloud className="h-5 w-5 text-primary" />
                  <span className="text-sm font-medium">Weather Conditions</span>
                </div>
                <p className="mt-1 text-2xl font-bold text-primary">
                  {selectedLocation.weather[0].main}
                </p>
                <p className="text-sm text-muted-foreground mt-1">
                  {selectedLocation.weather[0].description}
                </p>
                <p className="text-xs text-muted-foreground mt-2">
                  Feels like: {selectedLocation.main.feels_like?.toFixed(1)}°C
                </p>
              </div>

              <div className="p-6">
                <div className="flex items-center space-x-2 mb-3">
                  <Thermometer className="h-5 w-5 text-orange-500" />
                  <span className="text-sm font-medium">Temperature & Humidity</span>
                </div>
                <p className="mt-1 text-2xl font-bold text-orange-500">
                  {selectedLocation.main.temp.toFixed(1)}°C
                </p>
                <div className="grid grid-cols-2 gap-2 mt-2">
                  <p className="text-sm text-muted-foreground">
                    <span className="font-medium">💧 Humidity:</span><br/>
                    {selectedLocation.main.humidity}%
                  </p>
                  <p className="text-sm text-muted-foreground">
                    <span className="font-medium">📊 Pressure:</span><br/>
                    {selectedLocation.main.pressure} hPa
                  </p>
                </div>
              </div>

              <div className="p-6">
                <div className="flex items-center space-x-2 mb-3">
                  <Wind className="h-5 w-5 text-green-500" />
                  <span className="text-sm font-medium">Wind Information</span>
                </div>
                <p className="mt-1 text-2xl font-bold text-green-500">
                  {selectedLocation.wind.speed} m/s
                </p>
                <div className="mt-2">
                  <p className="text-sm text-muted-foreground">
                    <span className="font-medium">Wind Direction:</span><br/>
                    {selectedLocation.wind.deg ? `${selectedLocation.wind.deg}°` : 'N/A'}
                  </p>
                  {selectedLocation.wind.gust && (
                    <p className="text-sm text-muted-foreground mt-1">
                      <span className="font-medium">Gusts:</span><br/>
                      {selectedLocation.wind.gust} m/s
                    </p>
                  )}
                </div>
              </div>
            </div>
          )}
        </div>
  );
};

export default WeatherMap;