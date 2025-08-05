import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { ThemeProvider } from "@/hooks/use-theme";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Home from "./pages/Home";
import WeatherMapPage from "./pages/WeatherMapPage";
import SensorDataPage from "./pages/SensorDataPage";
import MLOutputPage from "./pages/MLOutputPage";
import ModelPage from "./pages/ModelPage";
import NotFound from "./pages/NotFound";

const queryClient = new QueryClient();

const App = () => (
  <QueryClientProvider client={queryClient}>
    <ThemeProvider>
      <TooltipProvider>
        <Toaster />
        <Sonner />
        <BrowserRouter>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/weather-map" element={<WeatherMapPage />} />
          <Route path="/sensor-data" element={<SensorDataPage />} />
          <Route path="/ml-output" element={<MLOutputPage />} />
          <Route path="/3d-model" element={<ModelPage />} />
          {/* ADD ALL CUSTOM ROUTES ABOVE THE CATCH-ALL "*" ROUTE */}
          <Route path="*" element={<NotFound />} />
        </Routes>
      </BrowserRouter>
      </TooltipProvider>
    </ThemeProvider>
  </QueryClientProvider>
);

export default App;
