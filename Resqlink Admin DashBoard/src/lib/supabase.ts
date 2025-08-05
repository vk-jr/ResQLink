import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_SECRET_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseKey);

// Sample sensor data types
export interface SensorData {
  id: number;
  timestamp: string;
  notification: string;
  alert: string;
  landslide_risk: string;
  predicted_soil_moisture: number;
  predicted_pore_pressure: number;
  risk_probability: number;
  confidence: number;
  reasoning: string;
  rainfall_24h_mm: number;
  rainfall_3h_mm: number;
  soil_type: string;
  slope_degrees: number;
}

// ML Prediction types
export interface MLPrediction {
  id: string;
  timestamp: string;
  prediction: 'safe' | 'warning' | 'danger';
  confidence: number;
  recommendation: string;
}