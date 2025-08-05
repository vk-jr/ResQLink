import os
import sys
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.metrics import mean_absolute_error, accuracy_score, classification_report, r2_score, confusion_matrix
from sklearn.preprocessing import LabelEncoder
from weather_data import get_weather_data_shirur, SHIRUR_INFO

# Add path to current directory to make sure we can find the data file
current_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(current_dir)

# --- 1. Load and Prepare the Data ---
data_file = os.path.join(current_dir, 'landslide_data_500.csv')
if not os.path.exists(data_file):
    raise FileNotFoundError(f"Error: {data_file} not found. Make sure the CSV file is in the correct directory.")

# Load the dataset
data = pd.read_csv(data_file)

# Convert categorical 'soil_type' to numbers
le = LabelEncoder() 
data['soil_type_encoded'] = le.fit_transform(data['soil_type'])

# Define features (X) and targets (y)
# Features for the first prediction step (predicting tomorrow's conditions)
features_step1 = ['rainfall_24h_mm', 'rainfall_3h_mm', 'soil_moisture_pct', 'pore_water_pressure_kpa', 
                 'soil_type_encoded', 'slope_degrees', 'expected_tomorrow_rainfall_24h_mm']

def main():
    # Targets for the first step
    targets_step1 = ['tomorrows_soil_moisture_pct', 'tomorrows_pore_water_pressure_kpa']

    # Target for the second step (predicting landslide occurrence)
    target_step2 = 'landslide_tomorrow'

    # Split data for training and testing
    X_train, X_test, y_train, y_test = train_test_split(
        data[features_step1], 
        data[targets_step1 + [target_step2]], 
        test_size=0.2, 
        random_state=42
    )

    y_train_step1 = y_train[targets_step1]
    y_test_step1 = y_test[targets_step1]
    y_train_step2 = y_train[target_step2]
    y_test_step2 = y_test[target_step2]

    # --- 2. Step 1: Predict Tomorrow's Soil Moisture and Pore Water Pressure (Regression) ---
    print("--- Training Step 1: Predicting Tomorrow's Soil Conditions ---")

    # Initialize and train the regression model
    # A RandomForestRegressor is a good general-purpose model
    regressor = RandomForestRegressor(n_estimators=10000, random_state=42)
    regressor.fit(X_train, y_train_step1)

    # Make predictions on the test set
    predictions_step1 = regressor.predict(X_test)

    # Evaluate the regression model
    mae = mean_absolute_error(y_test_step1, predictions_step1)
    r2 = r2_score(y_test_step1, predictions_step1)
    print(f"Mean Absolute Error for predicting soil conditions: {mae:.2f}")
    print(f"R-squared for predicting soil conditions: {r2:.2f}")
    print("-" * 30)


    # --- 3. Step 2: Predict Landslide Risk (Classification) ---
    print("\n--- Training Step 2: Predicting Landslide Risk ---")

    # Prepare the training data for the classifier
    # The features are the original features PLUS the predicted conditions from Step 1
    X_train_step2 = X_train.copy()
    X_train_step2['predicted_soil_moisture'] = y_train_step1['tomorrows_soil_moisture_pct']
    X_train_step2['predicted_pore_pressure'] = y_train_step1['tomorrows_pore_water_pressure_kpa']

    # Initialize and train the classification model
    classifier = RandomForestClassifier(n_estimators=500, random_state=42)
    classifier.fit(X_train_step2, y_train_step2)

    # Prepare the test data for the classifier
    X_test_step2 = X_test.copy()
    X_test_step2['predicted_soil_moisture'] = predictions_step1[:, 0]  # First column of the regressor's output
    X_test_step2['predicted_pore_pressure'] = predictions_step1[:, 1] # Second column

    # Make the final landslide predictions
    predictions_step2 = classifier.predict(X_test_step2)

    # Evaluate the classification model
    accuracy = accuracy_score(y_test_step2, predictions_step2)
    cm = confusion_matrix(y_test_step2, predictions_step2)
    print(f"Accuracy of the landslide prediction model: {accuracy:.2f}")
    print("\nConfusion Matrix:")
    print(cm)
    print("\nClassification Report:")
    print(classification_report(y_test_step2, predictions_step2))
    print("-" * 30)


    # --- 4. Example: Predict for a New Day ---
    print("\n--- Example Prediction for New Data ---")

    # Fetch real-time weather data for Shirur
    weather_data = get_weather_data_shirur()

    # Create a new data point using real weather data and Shirur-specific information
    new_data_today = pd.DataFrame({
        'rainfall_24h_mm': [weather_data['current_24h_rain']],
        'rainfall_3h_mm': [weather_data['current_3h_rain']],
        'soil_moisture_pct': [SHIRUR_INFO['soil_moisture_pct']],  # Will be replaced with sensor data
        'pore_water_pressure_kpa': [SHIRUR_INFO['pore_water_pressure_kpa']],  # Will be replaced with sensor data
        'soil_type': [SHIRUR_INFO['soil_type']],
        'slope_degrees': [SHIRUR_INFO['slope_degrees']],
        'expected_tomorrow_rainfall_24h_mm': [weather_data['tomorrow_24h_rain']]
    })

    print("\n=== Current Conditions in Shirur ===")
    print(f"Last 24 Hours Rainfall: {weather_data['current_24h_rain']:.1f} mm")
    print(f"Last 3 Hours Rainfall: {weather_data['current_3h_rain']:.1f} mm")
    print(f"Soil Type: {SHIRUR_INFO['soil_type']}")
    print(f"Current Soil Moisture: {SHIRUR_INFO['soil_moisture_pct']:.1f}%")
    pore_water_pressure = SHIRUR_INFO['pore_water_pressure_kpa']
    if pore_water_pressure is not None:
        print(f"Current Pore Water Pressure: {pore_water_pressure:.1f} kPa")
    else:
        print("Current Pore Water Pressure: N/A kPa")
    print(f"Terrain Slope: {SHIRUR_INFO['slope_degrees']:.1f}°")

    print("\n=== Weather Forecast ===")
    print(f"Expected Rainfall Tomorrow: {weather_data['tomorrow_24h_rain']:.1f} mm")

    print("\n=== Full Input Data ===")
    print(new_data_today)

    # Preprocess the new data (encode 'soil_type')
    new_data_today['soil_type_encoded'] = le.transform(new_data_today['soil_type'])
    new_data_step1 = new_data_today[features_step1]

    # Step 1: Predict tomorrow's soil conditions for the new data
    predicted_conditions_new = regressor.predict(new_data_step1)
    print(f"\nPredicted Tomorrow's Soil Moisture: {predicted_conditions_new[0, 0]:.2f}%")
    print(f"Predicted Tomorrow's Pore Water Pressure: {predicted_conditions_new[0, 1]:.2f} kPa")

    # Step 2: Use predicted conditions to predict landslide risk
    new_data_step2 = new_data_step1.copy()
    new_data_step2['predicted_soil_moisture'] = predicted_conditions_new[:, 0]
    new_data_step2['predicted_pore_pressure'] = predicted_conditions_new[:, 1]

    final_prediction = classifier.predict(new_data_step2)
    final_prediction_proba = classifier.predict_proba(new_data_step2)

    print("\n--- Final Prediction ---")
    # Determine risk level based on probability
    prob = final_prediction_proba[0][1]
    if prob >= 0.7:
        risk_label = "High Risk"
    elif prob >= 0.3:
        risk_label = "Medium Risk"
    else:
        risk_label = "Low Risk"
    print(f"Predicted Landslide Risk for Tomorrow: {risk_label} (Probability: {prob:.2f})")

    # Calculate current model performance metrics
    current_accuracy = accuracy
    current_mae = mae
    current_r2 = r2

    print("\n=== Current Model Performance ===")
    print(f"Model Accuracy: {current_accuracy:.4f}")
    print(f"Mean Absolute Error: {current_mae:.4f}")
    print(f"R-squared Score: {current_r2:.4f}")

    # Save prediction results to database
    from database_connection import save_prediction_to_db

    # Prepare the prediction data
    predictions = {
        'soil_moisture': predicted_conditions_new[0, 0],
        'pore_pressure': predicted_conditions_new[0, 1],
        'model_accuracy': current_accuracy,
        'model_mae': current_mae,
        'model_r2': current_r2
    }

    risk_assessment = {
        'risk_level': risk_label,
        'probability': prob
    }

    # Save to database
    save_result = save_prediction_to_db(
        weather_data=weather_data,
        shirur_info=SHIRUR_INFO,
        predictions=predictions,
        risk_assessment=risk_assessment
    )

    if save_result:
        print("Prediction results and model metrics saved to database successfully")
    else:
        print("Warning: Failed to save prediction results to database")

    print("-" * 30)

# To run this code:
# 1. Make sure you have pandas and scikit-learn installed:
#    pip install pandas scikit-learn
# 2. Save the code as 'landslide_prediction.py'.
# 3. Place 'landslide_data.csv' in the same directory.
# 4. Run from your terminal: python landslide_prediction.py

if __name__ == "__main__":
    main()
