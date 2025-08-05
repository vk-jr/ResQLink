from supabase import create_client
from datetime import datetime

# Supabase configuration
SUPABASE_URL = "https://axhllqkehjppzhjyjumg.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF4aGxscWtlaGpwcHpoanlqdW1nIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MjIxODAxNCwiZXhwIjoyMDY3Nzk0MDE0fQ.m8Ye09Nt7pZf4cIdIQpNoC0hMzJXHl83KoiLgUSXy4A"

# Initialize Supabase client
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def save_prediction_to_db(weather_data, shirur_info, predictions, risk_assessment):
    """
    Save the prediction results and input data to Supabase
    """
    try:
        # Convert float values to proper numeric format and ensure boolean is properly handled
        data = {
            'soil_moisture': int(shirur_info['soil_moisture_pct']),
            'pore_water_pressure': float(shirur_info['pore_water_pressure_kpa']),
            'rainfall_24h_mm': float(weather_data['current_24h_rain']),
            'rainfall_3h_mm': float(weather_data['current_3h_rain']),
            'soil_type': str(shirur_info['soil_type']),
            'slope_degrees': float(shirur_info['slope_degrees']),
            'expected_tomorrow_rainfall_24h_mm': float(weather_data['tomorrow_24h_rain']),
            'predicted_soil_moisture': float(predictions['soil_moisture']),
            'predicted_pore_pressure': float(predictions['pore_pressure']),
            'landslide_risk': str(risk_assessment['risk_level']),
            'risk_probability': float(risk_assessment['probability']),
            'notification': f"Landslide Risk: {risk_assessment['risk_level']} (Probability: {risk_assessment['probability']:.2f})",
            'model_accuracy': float(predictions['model_accuracy']),
            'model_mae': float(predictions['model_mae']),
            'model_r2': float(predictions['model_r2'])
        }
        
        # Insert data into Supabase
        result = supabase.table('sensor_data').insert(data).execute()
        
        print("Successfully saved prediction to database")
        return result.data
        
    except Exception as e:
        print(f"Error saving to database: {e}")
        return None

def get_latest_predictions():
    """
    Retrieve the latest prediction from the database
    """
    try:
        result = supabase.table('sensor_data')\
            .select('*')\
            .order('timestamp', desc=True)\
            .limit(1)\
            .execute()
        
        return result.data[0] if result.data else None
        
    except Exception as e:
        print(f"Error retrieving from database: {e}")
        return None

def get_historical_data(days=7):
    """
    Retrieve historical predictions for the specified number of days
    """
    try:
        # Assuming hourly predictions
        result = supabase.table('sensor_data')\
            .select('*')\
            .order('timestamp', desc=True)\
            .limit(days * 24)\
            .execute()
        
        return result.data
        
    except Exception as e:
        print(f"Error retrieving historical data: {e}")
        return []

def get_latest_sensor_data():
    """Fetch the most recent sensor reading"""
    try:
        result = supabase.table('real_sensor_data')\
            .select('*')\
            .order('id', desc=True)\
            .limit(1)\
            .execute()
        
        print(f"Database query result: {result.data}")
        
        if result.data:
            return result.data[0]
        return None
        
    except Exception as e:
        print(f"Error fetching latest sensor data: {e}")
        return None

def save_sensor_reading(soil_moisture, pore_pressure):
    """Save new sensor reading to database"""
    try:
        data = {
            'soil_moisture': soil_moisture,
            'pore_pressure': pore_pressure,
            'timestamp': datetime.now().isoformat()
        }
        result = supabase.table('real_sensor_data').insert(data).execute()
        return result.data
    except Exception as e:
        print(f"Error saving sensor reading: {e}")
        return None
