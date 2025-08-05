import { useState } from "react";
import { useLocation } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { ThemeToggle } from "@/components/ThemeToggle";
import { 
  MapPin, 
  Activity, 
  Brain, 
  Home, 
  Menu, 
  X,
  Shield
} from "lucide-react";

interface LayoutProps {
  children: React.ReactNode;
}

const Layout = ({ children }: LayoutProps) => {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const location = useLocation();

  const navigation = [
    { name: "Home", href: "/", icon: Home },
    { name: "Live Weather Map", href: "/weather-map", icon: MapPin },
    { name: "Sensor Data", href: "/sensor-data", icon: Activity },
    { name: "ML Output", href: "/ml-output", icon: Brain },
    { name: "3D Model", href: "/3d-model", icon: Shield },
  ];

  const isActive = (href: string) => {
    if (href === "/") return location.pathname === "/";
    return location.pathname.startsWith(href);
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="bg-card/95 backdrop-blur-sm border-b border-border shadow-professional sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            {/* Logo */}
            <div className="flex items-center space-x-3">
              <img src="/resqlink-logo.png" alt="ResQlink Logo" className="h-10" />
              <div>
                <h1 className="text-xl font-bold text-primary tracking-wide">
                  Admin Panel
                </h1>
                <p className="text-xs text-muted-foreground font-medium uppercase tracking-wider">Geological Monitoring</p>
              </div>
            </div>

            {/* Desktop Navigation */}
            <nav className="hidden md:flex items-center space-x-2">
              {navigation.map((item) => {
                const Icon = item.icon;
                return (
                  <Button
                    key={item.name}
                    variant={isActive(item.href) ? "default" : "ghost"}
                    asChild
                    className={cn(
                      "flex items-center space-x-2 px-4 py-2 rounded-lg font-medium transition-all duration-200",
                      isActive(item.href) 
                        ? "bg-primary text-primary-foreground shadow-professional" 
                        : "hover:bg-secondary hover:text-secondary-foreground"
                    )}
                  >
                    <a href={item.href}>
                      <Icon className="h-4 w-4" />
                      <span className="text-sm">{item.name}</span>
                    </a>
                  </Button>
                );
              })}
              <div className="border-l border-border/50 ml-2 pl-2">
                <ThemeToggle />
              </div>
            </nav>

            {/* Mobile menu button */}
            <Button
              variant="ghost"
              size="sm"
              className="md:hidden"
              onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            >
              {isMobileMenuOpen ? (
                <X className="h-5 w-5" />
              ) : (
                <Menu className="h-5 w-5" />
              )}
            </Button>
          </div>
        </div>

        {/* Mobile Navigation */}
        {isMobileMenuOpen && (
          <div className="md:hidden border-t border-border bg-card animate-fade-in">
            <nav className="px-4 py-2 space-y-1">
              {navigation.map((item) => {
                const Icon = item.icon;
                return (
                  <Button
                    key={item.name}
                    variant={isActive(item.href) ? "default" : "ghost"}
                    asChild
                    className="w-full justify-start space-x-2"
                    onClick={() => setIsMobileMenuOpen(false)}
                  >
                    <a href={item.href}>
                      <Icon className="h-4 w-4" />
                      <span>{item.name}</span>
                    </a>
                  </Button>
                );
              })}
            </nav>
          </div>
        )}
      </header>

      {/* Main Content */}
      <main className="flex-1 bg-gradient-to-br from-background via-background to-muted/30 min-h-screen">
        <div className="p-6">
          {children}
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-card border-t border-border mt-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="text-center text-sm text-muted-foreground">
            <p>© 2024 ResQlink. Protecting communities through early warning systems.</p>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default Layout;