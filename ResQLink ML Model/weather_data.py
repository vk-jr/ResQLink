import requests
import json
from datetime import datetime

def get_weather_data_shirur():
    # WeatherAPI.com configuration
    API_KEY = "36c51f6fbacf4b3498c31144252707"
    # Shirur, Pune coordinates
    LAT = "18.8333"
    LON = "74.3333"
    
    # API endpoint for current weather and forecast
    url = f"http://api.weatherapi.com/v1/forecast.json?key={API_KEY}&q={LAT},{LON}&days=2&aqi=no"
    
    try:
        response = requests.get(url)
        data = response.json()
        
        # Get current day's rainfall
        current_day_rain = data['forecast']['forecastday'][0]['day']['totalprecip_mm']
        # Get last 3 hours rainfall (approximation from hourly data)
        current_hour = datetime.now().hour
        last_3h_rain = sum(
            hour['precip_mm'] 
            for hour in data['forecast']['forecastday'][0]['hour']
            if current_hour - 3 <= int(hour['time'].split()[1].split(':')[0]) <= current_hour
        )
        
        # Get tomorrow's forecasted rainfall
        tomorrow_rain = data['forecast']['forecastday'][1]['day']['totalprecip_mm']
        
        return {
            'current_24h_rain': current_day_rain,
            'current_3h_rain': last_3h_rain,
            'tomorrow_24h_rain': tomorrow_rain
        }
    except Exception as e:
        print(f"Error fetching weather data: {e}")
        # Return default values if API fails
        return {
            'current_24h_rain': 0,
            'current_3h_rain': 0,
            'tomorrow_24h_rain': 0
        }

def get_latest_conditions():
    """Fetch latest sensor readings from database"""
    from database_connection import get_latest_sensor_data
    sensor_data = get_latest_sensor_data()
    if sensor_data:
        return {
            'soil_moisture_pct': sensor_data['soil_moisture'],
            'pore_water_pressure_kpa': sensor_data['pore_water_pressure']  # Use actual value from database
        }
    print("No soil moisture data found in real_sensor_data table")
  
# Shirur specific soil and terrain information
SHIRUR_INFO = {
    'soil_type': 'clay',  # Predominant soil type in Shirur
    'slope_degrees': 35,   # Average slope in the region
    **get_latest_conditions()  # Dynamically get latest sensor readings
}
