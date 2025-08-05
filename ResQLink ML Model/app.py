from flask import Flask, jsonify
import threading
import time
import traceback
from datetime import datetime
import landslide_prediction
import os

app = Flask(__name__)

# Global variables to track prediction status
last_prediction_time = None
last_prediction_status = "Not started"
last_error = None

def run_prediction_loop():
    global last_prediction_time, last_prediction_status, last_error
    
    # Wait for 10 seconds before starting predictions to let Flask initialize
    time.sleep(10)
    
    while True:
        try:
            print(f"\n[{datetime.now()}] Starting landslide prediction...")
            last_prediction_status = "Running"
            
            # Run prediction
            landslide_prediction.main()
            
            # Update status
            last_prediction_time = datetime.now()
            last_prediction_status = "Success"
            last_error = None
            
            print(f"[{datetime.now()}] Prediction completed successfully")
            
        except Exception as e:
            last_prediction_status = "Failed"
            last_error = str(e)
            print(f"[{datetime.now()}] Error in prediction:")
            print(traceback.format_exc())
        
        # Wait for next interval
        time.sleep(300)  # 300 seconds = 5 minutes

# Start prediction thread
try:
    prediction_thread = threading.Thread(target=run_prediction_loop, daemon=True)
    prediction_thread.start()
    print("Prediction thread started successfully")
except Exception as e:
    print(f"Error starting prediction thread: {str(e)}")

@app.route('/')
def health_check():
    return jsonify({
        "status": "alive",
        "current_time": str(datetime.now()),
        "last_prediction_time": str(last_prediction_time) if last_prediction_time else None,
        "last_prediction_status": last_prediction_status,
        "last_error": last_error
    })

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    app.run(host='0.0.0.0', port=port)
