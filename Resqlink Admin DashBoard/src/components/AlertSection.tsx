import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { useToast } from "@/hooks/use-toast";
import { 
  Users, 
  UserCheck, 
  Siren, 
  Loader2,
  Phone,
  AlertTriangle
} from "lucide-react";
import { cn } from "@/lib/utils";

const AlertSection = () => {
  const [isLoading, setIsLoading] = useState<string | null>(null);
  const { toast } = useToast();

  const handleAlert = async (userType: 'citizen' | 'representative') => {
    setIsLoading(userType);
    
    try {
      const response = await fetch('https://razyergg.app.n8n.cloud/webhook/call-trigger', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          userType,
          timestamp: new Date().toISOString(),
          source: 'ResQlink_Admin_Panel'
        }),
      });

      if (response.ok) {
        toast({
          title: "Alert Triggered Successfully",
          description: `${userType === 'citizen' ? 'Citizens' : 'Representatives'} have been notified of the landslide risk.`,
          variant: "default",
        });
      } else {
        throw new Error('Failed to trigger alert');
      }
    } catch (error) {
      console.error('Error triggering alert:', error);
      toast({
        title: "Alert Failed",
        description: "Unable to send alert. Please try again or contact support.",
        variant: "destructive",
      });
    } finally {
      setIsLoading(null);
    }
  };

  return (
    <Card className="shadow-alert border-destructive/20 bg-destructive/5">
      <CardHeader>
        <CardTitle className="flex items-center space-x-2 text-destructive">
          <div className="p-2 bg-destructive/10 rounded-lg">
            <Siren className="h-5 w-5 animate-pulse-custom" />
          </div>
          <span>Emergency Alert System</span>
          <Badge variant="destructive" className="animate-pulse-custom">
            ACTIVE
          </Badge>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-6">
        <div className="text-center">
          <AlertTriangle className="h-12 w-12 text-destructive mx-auto mb-2 animate-pulse-custom" />
          <h3 className="text-lg font-semibold text-destructive mb-2">
            Landslide Risk Detected
          </h3>
          <p className="text-sm text-muted-foreground">
            Choose your notification target to trigger immediate alerts
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {/* Citizen Alert */}
          <Card className="border border-primary/20 hover:border-primary/40 transition-colors">
            <CardContent className="p-4 text-center">
              <div className="p-2 bg-primary/10 rounded-full w-fit mx-auto mb-2">
                <Users className="h-6 w-6 text-primary" />
              </div>
              <div className="space-y-1">
                <h4 className="font-semibold">Alert Citizens</h4>
                <p className="text-xs text-muted-foreground">
                  Notify all registered citizens in the risk zone via SMS, app notifications, and local sirens.
                </p>
                <div className="flex items-center justify-center space-x-1 text-xs text-muted-foreground">
                  <Phone className="h-3 w-3" />
                  <span>SMS + App + Sirens</span>
                </div>
              </div>
              <Button
                onClick={() => handleAlert('citizen')}
                disabled={isLoading === 'citizen'}
                className="w-full gradient-primary shadow-glow mt-3"
                size="sm"
              >
                {isLoading === 'citizen' ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Sending Alert...
                  </>
                ) : (
                  <>
                    <Users className="h-4 w-4 mr-2" />
                    I'm a Citizen
                  </>
                )}
              </Button>
            </CardContent>
          </Card>

          {/* Representative Alert */}
          <Card className="border border-accent/20 hover:border-accent/40 transition-colors">
            <CardContent className="p-4 text-center">
              <div className="p-2 bg-accent/10 rounded-full w-fit mx-auto mb-2">
                <UserCheck className="h-6 w-6 text-accent" />
              </div>
              <div className="space-y-1">
                <h4 className="font-semibold">Alert Representatives</h4>
                <p className="text-xs text-muted-foreground">
                  Notify government officials, emergency services, and local authorities for immediate response.
                </p>
                <div className="flex items-center justify-center space-x-1 text-xs text-muted-foreground">
                  <Phone className="h-3 w-3" />
                  <span>Emergency Contacts</span>
                </div>
              </div>
              <Button
                onClick={() => handleAlert('representative')}
                disabled={isLoading === 'representative'}
                className="w-full gradient-success mt-3"
                size="sm"
              >
                {isLoading === 'representative' ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Sending Alert...
                  </>
                ) : (
                  <>
                    <UserCheck className="h-4 w-4 mr-2" />
                    I'm a Representative
                  </>
                )}
              </Button>
            </CardContent>
          </Card>
        </div>

        <div className="text-center pt-4 border-t border-border">
          <p className="text-xs text-muted-foreground">
            Alerts are sent immediately and logged for emergency response tracking.
          </p>
        </div>
      </CardContent>
    </Card>
  );
};

export default AlertSection;