import { Card } from "@/components/ui/card";
import Layout from "@/components/Layout";

export default function ModelPage() {
  return (
    <Layout>
      <Card className="w-full h-[calc(100vh-4rem)]">
        <iframe
          src="https://landslide-simulator-ellysteffen.replit.app"
          className="w-full h-full border-none"
          title="3D Landslide Model"
        />
      </Card>
    </Layout>
  );
}
