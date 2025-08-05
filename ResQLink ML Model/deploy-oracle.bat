@echo off
echo 🚀 Oracle Cloud (OKE) Deployment Helper
echo.

echo 📋 Checking prerequisites...
where kubectl >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ kubectl not found! Please install kubectl first.
    echo 📚 Visit: https://kubernetes.io/docs/tasks/tools/install-kubectl/
    pause
    exit /b 1
)

where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker not found! Please install Docker Desktop first.
    pause
    exit /b 1
)

echo ✅ Prerequisites check passed!
echo.

echo 🎯 Oracle Cloud Setup Guide:
echo.
echo 📝 Step 1: Create Oracle Cloud Account
echo    1. Go to cloud.oracle.com
echo    2. Click "Start for free"
echo    3. Sign up and get $200 free credit
echo    4. Verify your account
echo.

echo 📝 Step 2: Create OKE Cluster
echo    1. Log into Oracle Cloud Console
echo    2. Go to Developer Services > Kubernetes Clusters (OKE)
echo    3. Click "Create Cluster"
echo    4. Choose "Quick Create"
echo    5. Configure:
echo       - Name: ml-cluster
echo       - Node pool: 1 node
echo       - Node shape: VM.Standard.A1.Flex (free tier)
echo       - Memory: 6GB, OCPUs: 1
echo.

echo 📝 Step 3: Configure kubectl
echo    1. Go to your OKE cluster
echo    2. Click "Access Cluster"
echo    3. Download kubeconfig file
echo    4. Set KUBECONFIG environment variable:
echo       set KUBECONFIG=C:\path\to\your\kubeconfig
echo.

echo 📝 Step 4: Set Up Container Registry
echo    1. Go to Developer Services > Container Registry
echo    2. Click "Create Repository"
echo    3. Name: landslide-ml-app
echo    4. Generate Auth Token in OCI Console
echo    5. Login: docker login <region>.ocir.io
echo.

echo 📝 Step 5: Build and Deploy
echo    1. Build image:
echo       docker build -t <region>.ocir.io/<tenancy-namespace>/landslide-ml-app:latest .
echo.
echo    2. Push image:
echo       docker push <region>.ocir.io/<tenancy-namespace>/landslide-ml-app:latest
echo.
echo    3. Update deployment file:
echo       Replace "your-registry/landslide-ml-app:latest" with your actual registry URL
echo.
echo    4. Deploy:
echo       kubectl apply -f k8s-oracle-deployment.yaml
echo.

echo 💰 Oracle Cloud Pricing:
echo    ✅ $200 free credit (30 days)
echo    ✅ Always Free resources available
echo    ✅ OKE: ~$50/month after free tier
echo    ✅ Load Balancer: ~$20/month after free tier
echo    ✅ Container Registry: FREE
echo.

echo 🎯 Oracle Cloud Advantages:
echo    ✅ Enterprise-grade security
echo    ✅ Global infrastructure
echo    ✅ Cost-effective pricing
echo    ✅ Free container registry
echo    ✅ Integrated monitoring
echo.

echo 📊 After deployment, monitor with:
echo    kubectl get pods
echo    kubectl logs -f deployment/landslide-ml-app
echo    kubectl get services
echo.

echo 🔍 Troubleshooting:
echo    - Check OCI Console for cluster status
echo    - Verify kubeconfig is correct
echo    - Check container registry authentication
echo    - Review security lists and VCN configuration
echo.

echo 🎉 Your ML app will run every 3 minutes automatically!
echo 📚 For detailed instructions, see oracle-deploy-guide.md
echo.

pause 