import time
from datetime import datetime
import landslide_prediction

def run_prediction():
    while True:
        try:
            print(f"\n[{datetime.now()}] Starting landslide prediction...")
            landslide_prediction.main()
            print(f"[{datetime.now()}] Prediction completed successfully")
        except Exception as e:
            print(f"[{datetime.now()}] Error in prediction: {str(e)}")
        
        # Wait for 5 minutes before next prediction
        time.sleep(300)  # 300 seconds = 5 minutes

if __name__ == "__main__":
    run_prediction()
