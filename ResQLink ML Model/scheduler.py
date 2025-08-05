import schedule
import time
import subprocess
import sys
from datetime import datetime

def run_prediction():
    """Run the landslide prediction script"""
    try:
        print(f"\n[{datetime.now()}] Running landslide prediction...")
        # Run the prediction script
        result = subprocess.run([sys.executable, 'landslide_prediction.py'], 
                              capture_output=True, 
                              text=True)
        
        if result.returncode == 0:
            print(f"[{datetime.now()}] Prediction completed successfully")
            print(result.stdout)  # Print the prediction results
        else:
            print(f"[{datetime.now()}] Error running prediction:")
            print(result.stderr)
    except Exception as e:
        print(f"[{datetime.now()}] Error: {str(e)}")

def main():
    # Run once immediately at startup
    run_prediction()
    
    # Schedule to run every 10 minutes
    schedule.every(10).minutes.do(run_prediction)
    
    print("Scheduler started. Will run predictions every 10 minutes.")
    
    # Keep the script running
    while True:
        try:
            schedule.run_pending()
            time.sleep(1)
        except Exception as e:
            print(f"Error in scheduler: {str(e)}")
            # Wait a bit before retrying
            time.sleep(60)

if __name__ == "__main__":
    main()
