# ResQLink Guardian - Admin Dashboard

## Overview
ResQLink Guardian is an administrative dashboard for managing disaster response and monitoring. It provides real-time visualization of landslide data, risk assessment, and emergency response coordination.

## Features
- 📊 Real-time data visualization
- 🗺️ Landslide susceptibility mapping
- ⚠️ Risk assessment analytics
- 🚨 Alert management system
- 👥 User management
- 📱 Responsive design

## Tech Stack
- **Frontend Framework**: React with TypeScript
- **Build Tool**: Vite
- **UI Components**: shadcn/ui
- **Styling**: Tailwind CSS
- **Form Handling**: React Hook Form
- **UI Components**: Radix UI primitives
- **Type Safety**: TypeScript

## Getting Started

### Prerequisites
- Node.js (Latest LTS version)
- npm or bun package manager

### Installation

```bash
# Clone the repository
git clone https://github.com/vk-jr/resqlink-guardian.git

# Navigate to project directory
cd resqlink-guardian

# Install dependencies
npm install
# or
bun install

# Start development server
npm run dev
# or
bun run dev
```

### Available Scripts
- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run build:dev` - Build for development
- `npm run lint` - Run ESLint
- `npm run preview` - Preview production build

## Project Structure
```
├── public/               # Static assets
├── src/
│   ├── components/       # Reusable UI components
│   ├── hooks/           # Custom React hooks
│   ├── lib/             # Utility functions and configurations
│   ├── pages/           # Page components
│   ├── App.tsx          # Root component
│   └── main.tsx         # Entry point
├── components.json       # shadcn/ui configuration
├── tailwind.config.ts   # Tailwind CSS configuration
└── vite.config.ts       # Vite configuration
```

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Environment Setup
Create a `.env` file in the root directory with necessary environment variables.

## Building for Production

```bash
# Build the project
npm run build

# Preview the build
npm run preview
```

## License
This project is proprietary and confidential.

## Acknowledgments
- Built with [shadcn/ui](https://ui.shadcn.com/)
- Powered by [Vite](https://vitejs.dev/)
- Styled with [Tailwind CSS](https://tailwindcss.com/)
