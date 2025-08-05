import pandas as pd
import numpy as np

# Function to generate realistic landslide data
def generate_landslide_data(n_samples=500):
    data = []
    soil_types = ['sandy', 'silty', 'clay']
    
    for _ in range(n_samples):
        # Generate realistic rainfall patterns
        rainfall_24h = np.random.choice([
            np.random.uniform(0, 64.4),      # Light rain (60% chance)
            np.random.uniform(64.5, 115.5),   # Moderate rain (25% chance)
            np.random.uniform(115.6, 204.4),  # Heavy rain (10% chance)
            np.random.uniform(204.5, 300)     # Extreme rain (5% chance)
        ], p=[0.6, 0.25, 0.1, 0.05])
        
        # 3h rainfall is typically 20-30% of 24h rainfall
        rainfall_3h = rainfall_24h * np.random.uniform(0.2, 0.3)
        
        # Generate tomorrow's expected rainfall
        expected_tomorrow_rainfall = np.random.choice([
            np.random.uniform(0, 64.4),      # Light rain (55% chance)
            np.random.uniform(64.5, 115.5),   # Moderate rain (25% chance)
            np.random.uniform(115.6, 204.4),  # Heavy rain (15% chance)
            np.random.uniform(204.5, 300)     # Extreme rain (5% chance)
        ], p=[0.55, 0.25, 0.15, 0.05])
        
        # Select soil type
        soil_type = np.random.choice(soil_types)
        
        # Slope degrees (more likely to be moderate)
        slope = np.random.normal(30, 8)
        slope = max(min(slope, 45), 10)  # Constrain between 10 and 45 degrees
        
        # Base soil moisture depends on soil type and recent rainfall
        base_moisture = {
            'sandy': np.random.uniform(20, 35),
            'silty': np.random.uniform(30, 45),
            'clay': np.random.uniform(35, 55)
        }[soil_type]
        
        soil_moisture = base_moisture + (rainfall_24h/200 * 10)
        soil_moisture = max(min(soil_moisture, 60), 20)
        
        # Pore water pressure increases with soil moisture and rainfall
        pore_pressure = (soil_moisture * 0.3) + (rainfall_24h * 0.05)
        pore_pressure = max(min(pore_pressure, 35), 7)
        
        # Tomorrow's conditions based on today's conditions and soil type
        moisture_increase = (rainfall_24h * 0.15) * {
            'sandy': 0.7,
            'silty': 1.0,
            'clay': 1.3
        }[soil_type]
        
        tomorrow_moisture = soil_moisture + moisture_increase
        tomorrow_moisture = max(min(tomorrow_moisture, 75), 20)
        
        tomorrow_pressure = pore_pressure + (moisture_increase * 0.8)
        tomorrow_pressure = max(min(tomorrow_pressure, 45), 7)
        
        # Determine landslide risk
        # Higher risk with: high rainfall, steep slopes, clay soil, high pore pressure
        risk_score = (
            (rainfall_24h / 300) * 0.3 +
            (slope / 45) * 0.2 +
            (tomorrow_moisture / 75) * 0.25 +
            (tomorrow_pressure / 45) * 0.25
        )
        
        landslide = 1 if risk_score > 0.7 else 0
        
        data.append([
            round(rainfall_24h, 1),
            round(rainfall_3h, 1),
            round(soil_moisture, 1),
            round(pore_pressure, 1),
            soil_type,
            round(slope, 1),
            round(expected_tomorrow_rainfall, 1),
            round(tomorrow_moisture, 1),
            round(tomorrow_pressure, 1),
            landslide
        ])
    
    return pd.DataFrame(data, columns=[
        'rainfall_24h_mm',
        'rainfall_3h_mm',
        'soil_moisture_pct',
        'pore_water_pressure_kpa',
        'soil_type',
        'slope_degrees',
        'expected_tomorrow_rainfall_24h_mm',
        'tomorrows_soil_moisture_pct',
        'tomorrows_pore_water_pressure_kpa',
        'landslide_tomorrow'
    ])

# Generate and save the data
data = generate_landslide_data(500)
data.to_csv('landslide_data_500.csv', index=False)
print("Generated 500 realistic landslide data points")
