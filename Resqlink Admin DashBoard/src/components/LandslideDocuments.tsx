import { useState, useEffect, useCallback } from 'react';
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { 
  ChevronLeft, 
  ChevronRight, 
  Play, 
  Pause, 
  Maximize2
} from "lucide-react";

interface ImageData {
  src: string;
  title: string;
}

const images: ImageData[] = [
  {
    src: "/Landslide_inventory.png",
    title: "Landslide Inventory"
  },
  {
    src: "/Landslide_Susceptibility.jpg",
    title: "Landslide Susceptibility"
  },
  {
    src: "/Risk.png",
    title: "Risk Assessment"
  },
  {
    src: "/kerala.png",
    title: "Kerala Landslide Map"
  }
];

const LandslideDocuments = () => {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isFullscreen, setIsFullscreen] = useState(false);

  const nextImage = useCallback(() => {
    setCurrentIndex((prevIndex) => (prevIndex + 1) % images.length);
  }, []);

  const previousImage = () => {
    setCurrentIndex((prevIndex) => (prevIndex - 1 + images.length) % images.length);
  };

  const toggleFullscreen = () => {
    const element = document.getElementById('image-container');
    if (!document.fullscreenElement && element) {
      element.requestFullscreen().catch((err) => {
        console.error(`Error attempting to enable fullscreen: ${err.message}`);
      });
      setIsFullscreen(true);
    } else {
      document.exitFullscreen();
      setIsFullscreen(false);
    }
  };

  useEffect(() => {
    const intervalId = setInterval(nextImage, 4000); // 5 second delay for autoplay
    return () => clearInterval(intervalId);
  }, [nextImage]);

  return (
    <Card className="shadow-xl">
      <CardContent className="p-6">
        <div className="text-2xl font-bold mb-6 flex items-center justify-between">
          <span>Landslide Documents</span>
          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              size="icon"
              onClick={toggleFullscreen}
              className="h-8 w-8"
            >
              <Maximize2 className="h-4 w-4" />
            </Button>
          </div>
        </div>

        <div className="w-full overflow-hidden">
          {/* Image Section */}
          <div 
            id="image-container" 
            className={`relative ${isFullscreen ? 'fixed inset-0 z-50 bg-background' : ''}`}
          >
            <div className="flex transition-transform duration-500 ease-in-out" 
                 style={{ transform: `translateX(-${(currentIndex * 33.333)}%)` }}>
              {[...images, ...images.slice(0, 2)].map((image, index) => (
                <div key={index} className="w-1/3 flex-shrink-0 px-2">
                  <div className="aspect-[4/3] relative">
                    <img
                      src={image.src}
                      alt={image.title}
                      className="w-full h-full object-contain"
                    />
                  </div>
                  <div className="mt-2">
                    <p className="text-sm font-medium text-center">{image.title}</p>
                  </div>
                </div>
              ))}
              


              {/* Image Indicators */}
              <div className="absolute bottom-4 left-1/2 transform -translate-x-1/2 flex space-x-2">
                {images.map((_, index) => (
                  <button
                    key={index}
                    className={`w-2 h-2 rounded-full transition-all ${
                      index === currentIndex
                        ? 'bg-primary w-4'
                        : 'bg-primary/50'
                    }`}
                    onClick={() => setCurrentIndex(index)}
                  />
                ))}
              </div>
            </div>
          </div>


        </div>
      </CardContent>
    </Card>
  );
};

export default LandslideDocuments;
