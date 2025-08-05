from datetime import datetime
import landslide_prediction
import traceback

def run_prediction_task():
    try:
        print(f"\n[{datetime.now()}] Starting landslide prediction task...")
        # Run the prediction
        landslide_prediction.main()
        print(f"[{datetime.now()}] Task completed successfully")
        return True
    except Exception as e:
        print(f"[{datetime.now()}] Error in prediction task:")
        print(traceback.format_exc())
        return False

if __name__ == "__main__":
    run_prediction_task()
