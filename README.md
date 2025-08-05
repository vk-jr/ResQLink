# ResQLink - "Linking Help to Hope"

ResQLink is a comprehensive disaster management and emergency response system that combines mobile applications, machine learning, and IoT sensors to predict and respond to landslide disasters. The system consists of three main components:

## 🏗 Project Structure

```
ResQLink/
├── ResQlink Application/     # Flutter Mobile App
├── Resqlink Admin DashBoard/ # React Admin Dashboard
└── ResQLink ML Model/        # Python ML Service
```

## 📱 ResQlink Mobile Application

A Flutter-based mobile application designed for emergency response and community safety.

### Key Features
- Real-time Emergency Alerts
- Community Support System
- Interactive Map Interface
- Medical Chat Support
- Weather Monitoring
- SOS System with Location Tracking
- Safety Guidelines

### Technical Stack
- Flutter SDK (^3.8.0)
- Key Dependencies:
  - supabase_flutter: Backend and real-time data
  - flutter_map: Interactive mapping
  - geolocator: Location services
  - flutter_webrtc: Real-time communication
  - flutter_local_notifications: Alert system

### Core Functionalities
1. **Emergency Response System**
   - SOS button with location tracking
   - Emergency alert notifications
   - Flashlight and sound alerts

2. **Location Services**
   - Real-time location tracking
   - Geofencing for danger zones
   - Interactive map interface

3. **Community Features**
   - Community chat system
   - Medical assistance chat
   - Emergency contact management

4. **Weather Monitoring**
   - Real-time weather updates
   - Weather alerts and warnings
   - Integration with weather APIs

## 💻 Resqlink Admin Dashboard

A React-based web application for administrative control and monitoring.

### Key Features
- Alert Management System
- Emergency Map Visualization
- Landslide Documentation
- Sensor Data Dashboard
- ML Output Monitoring
- Weather Mapping

### Technical Stack
- TypeScript
- React
- Vite
- Tailwind CSS
- Shadcn UI Components

### Core Components
1. **Emergency Management**
   - Alert Section
   - Emergency Map
   - SOS Response System

2. **Data Visualization**
   - Sensor Dashboard
   - Weather Map
   - ML Output Cards

3. **Documentation**
   - Landslide Documentation
   - Risk Assessment
   - Resource Management

## 🤖 ResQLink ML Model

A Python-based machine learning service for landslide prediction.

### Key Features
- Real-time Landslide Prediction
- Weather Data Integration
- Soil Condition Monitoring
- Automated Alert Generation

### Technical Stack
- Python
- Flask
- scikit-learn
- pandas
- Docker

### Core Components
1. **Prediction System**
   - Two-step prediction model:
     - Step 1: Soil condition prediction
     - Step 2: Landslide risk classification
   - Features:
     - Rainfall data (24h and 3h)
     - Soil moisture
     - Pore water pressure
     - Soil type
     - Slope analysis

2. **Weather Integration**
   - Real-time weather data fetching
   - Rainfall prediction
   - Weather pattern analysis

3. **Deployment**
   - Docker containerization
   - Kubernetes support
   - Oracle Cloud deployment options

## 🔄 System Integration

The three components work together to provide a comprehensive disaster management system:

1. **Data Flow**
   - IoT sensors → ML Model → Admin Dashboard
   - ML Model → Mobile App (Alerts)
   - Mobile App → Admin Dashboard (SOS)

2. **Communication**
   - Real-time updates via Supabase
   - WebRTC for emergency communications
   - Push notifications for alerts

3. **Monitoring**
   - Continuous sensor data analysis
   - Real-time risk assessment
   - Automated alert generation

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.8.0)
- Node.js
- Python 3.8+
- Docker (optional)

### Environment Setup
1. Clone the repository
2. Set up environment variables
3. Install dependencies for each component
4. Run development servers

For detailed setup instructions, refer to individual component READMEs.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.

---

For more information or support, please contact the development team.ResQLink
“Linking Help to Hope”
