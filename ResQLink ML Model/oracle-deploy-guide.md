# 🚀 Deploy ML App to Oracle Cloud (OKE)

## 🎯 Why Oracle Cloud?

### ✅ **Oracle Cloud Advantages:**
- **Free Tier**: $200 free credit + Always Free resources
- **OKE (Oracle Kubernetes Engine)**: Managed Kubernetes service
- **OCI Container Registry**: Free container registry
- **Global Infrastructure**: Data centers worldwide
- **Enterprise Security**: Military-grade security
- **Cost Effective**: Often cheaper than AWS/Azure

### 💰 **Oracle Cloud Free Tier:**
- **$200 free credit** for 30 days
- **Always Free** resources:
  - 2 AMD-based Compute VMs
  - 24GB memory total
  - 200GB total storage
  - Load balancer
  - Container registry

## 📋 Prerequisites

1. **Oracle Cloud Account** (Free tier available)
2. **OCI CLI** installed
3. **kubectl** installed
4. **Docker** installed

## 🚀 Step-by-Step Oracle Cloud Deployment

### Step 1: Create Oracle Cloud Account
1. Go to [cloud.oracle.com](https://cloud.oracle.com)
2. Click "Start for free"
3. Sign up with email
4. Verify your account
5. Get your **$200 free credit**

### Step 2: Create OKE Cluster
1. **Log into Oracle Cloud Console**
2. **Navigate to Developer Services > Kubernetes Clusters (OKE)**
3. **Click "Create Cluster"**
4. **Choose "Quick Create"** (easiest for beginners)
5. **Configure:**
   - **Compartment**: Your compartment
   - **Name**: `ml-cluster`
   - **Kubernetes version**: Latest
   - **Node pool**: 1 node (free tier)
   - **Node shape**: VM.Standard.A1.Flex (free tier)
   - **Memory**: 6GB
   - **OCPUs**: 1
   - **Boot volume**: 50GB

### Step 3: Configure kubectl
1. **Download kubeconfig**:
   - Go to your OKE cluster
   - Click "Access Cluster"
   - Download the kubeconfig file

2. **Set up kubectl**:
   ```bash
   # Set KUBECONFIG environment variable
   export KUBECONFIG=/path/to/your/kubeconfig
   
   # Test connection
   kubectl get nodes
   ```

### Step 4: Set Up OCI Container Registry
1. **Enable Container Registry**:
   - Go to Developer Services > Container Registry
   - Click "Create Repository"
   - Name: `landslide-ml-app`

2. **Login to Registry**:
   ```bash
   # Login to Oracle Container Registry
   docker login <region>.ocir.io
   # Username: <tenancy-namespace>/<username>
   # Password: Auth Token (generate from OCI Console)
   ```

### Step 5: Build and Push Docker Image
```bash
# Build image
docker build -t <region>.ocir.io/<tenancy-namespace>/landslide-ml-app:latest .

# Push to Oracle Container Registry
docker push <region>.ocir.io/<tenancy-namespace>/landslide-ml-app:latest
```

### Step 6: Deploy to OKE
```bash
# Update image name in deployment file
sed -i 's|your-registry/landslide-ml-app:latest|<region>.ocir.io/<tenancy-namespace>/landslide-ml-app:latest|g' k8s-oracle-deployment.yaml

# Deploy
kubectl apply -f k8s-oracle-deployment.yaml
```

## 🔧 Oracle Cloud Specific Features

### 1. **OCI Load Balancer**
```yaml
annotations:
  service.beta.kubernetes.io/oci-load-balancer-shape: "flexible"
  service.beta.kubernetes.io/oci-load-balancer-shape-flex-min: "10"
  service.beta.kubernetes.io/oci-load-balancer-shape-flex-max: "100"
```

### 2. **OCI Container Registry**
- Free container registry
- Integrated with OKE
- Automatic image scanning

### 3. **OCI Monitoring**
- Built-in monitoring
- Cloud Guard security
- Performance insights

## 📊 Monitor Your Deployment

```bash
# Check if pods are running
kubectl get pods

# View logs
kubectl logs -f deployment/landslide-ml-app

# Check service (get Load Balancer IP)
kubectl get services

# Monitor resources
kubectl top pods
```

## 💰 Cost Breakdown

### Free Tier (First 30 days):
- **$200 free credit**
- OKE cluster: ~$50/month (covered by credit)
- Load balancer: ~$20/month (covered by credit)
- Container registry: Free
- **Total**: ~$70/month (covered by $200 credit)

### Always Free Resources:
- 2 AMD-based Compute VMs
- 24GB memory total
- 200GB storage
- Load balancer
- Container registry

### After Free Tier:
- **OKE**: ~$50/month
- **Load Balancer**: ~$20/month
- **Total**: ~$70/month

## 🛡️ Security Features

### 1. **Network Security**
- VCN (Virtual Cloud Network)
- Security lists
- Network security groups

### 2. **Identity and Access Management**
- IAM policies
- Service accounts
- API key management

### 3. **Container Security**
- Image scanning
- Vulnerability assessment
- Runtime security

## 🔄 Scaling Options

### 1. **Horizontal Pod Autoscaler**
```bash
kubectl autoscale deployment landslide-ml-app --cpu-percent=70 --min=1 --max=5
```

### 2. **Cluster Autoscaler**
- Automatically scales node pool
- Based on resource demand
- Cost optimization

### 3. **Manual Scaling**
```bash
# Scale to 3 replicas
kubectl scale deployment landslide-ml-app --replicas=3
```

## 🎯 Oracle Cloud vs Other Providers

| Feature | Oracle Cloud | AWS | Azure | Google Cloud |
|---------|-------------|-----|-------|--------------|
| Free Credit | $200 | $200 | $200 | $300 |
| Always Free | ✅ | ❌ | ❌ | ❌ |
| OKE Cost | $50/month | $73/month | $73/month | $73/month |
| Load Balancer | $20/month | $18/month | $18/month | $18/month |
| Container Registry | Free | $0.10/GB | $0.10/GB | $0.026/GB |

## 🚀 Quick Start Commands

```bash
# 1. Install OCI CLI
# Download from: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm

# 2. Configure OCI CLI
oci setup config

# 3. Create OKE cluster (via Console or CLI)
# 4. Download kubeconfig

# 5. Build and push image
docker build -t <region>.ocir.io/<tenancy-namespace>/landslide-ml-app:latest .
docker push <region>.ocir.io/<tenancy-namespace>/landslide-ml-app:latest

# 6. Deploy
kubectl apply -f k8s-oracle-deployment.yaml

# 7. Monitor
kubectl get pods
kubectl logs -f deployment/landslide-ml-app
```

## 🔍 Troubleshooting

### Common Issues:

1. **Authentication Errors**:
   ```bash
   # Regenerate auth token in OCI Console
   # Update docker login credentials
   ```

2. **Image Pull Errors**:
   ```bash
   # Check image exists in registry
   # Verify authentication
   # Check network connectivity
   ```

3. **Pod Not Starting**:
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

4. **Load Balancer Issues**:
   ```bash
   # Check security lists
   # Verify VCN configuration
   # Check service annotations
   ```

## 📚 Oracle Cloud Resources

- [Oracle Cloud Free Tier](https://www.oracle.com/cloud/free/)
- [OKE Documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm)
- [OCI Container Registry](https://docs.oracle.com/en-us/iaas/Content/Registry/home.htm)
- [OCI CLI Setup](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)

## 🎉 What You Get

After deployment to Oracle Cloud:
- ✅ **24/7 running ML app**
- ✅ **Automatic restarts** if it crashes
- ✅ **Enterprise-grade security**
- ✅ **Global load balancing**
- ✅ **Cost-effective pricing**
- ✅ **Free tier benefits**

---

**🚀 Ready to deploy?** Oracle Cloud offers excellent value with its free tier and competitive pricing. Your ML app will run reliably with enterprise-grade infrastructure! 