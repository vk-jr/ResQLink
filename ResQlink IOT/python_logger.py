import serial
import json
import threading
import time
import sys
import os
from dotenv import load_dotenv
from supabase import create_client, Client

# --- SUPABASE SETUP ---
load_dotenv()
url: str = "https://axhllqkehjppzhjyjumg.supabase.co"
key: str = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF4aGxscWtlaGpwcHpoanlqdW1nIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MjIxODAxNCwiZXhwIjoyMDY3Nzk0MDE0fQ.m8Ye09Nt7pZf4cIdIQpNoC0hMzJXHl83KoiLgUSXy4A"

if not url or not key:
    print("Error: SUPABASE_URL and SUPABASE_KEY must be set in the .env file.")
    sys.exit(1)

try:
    supabase: Client = create_client(url, key)
    print("Successfully connected to Supabase.")
except Exception as e:
    print(f"Error connecting to Supabase: {e}")
    sys.exit(1)

# --- SERIAL SETUP ---
SERIAL_PORT = '/dev/ttyUSB0'
BAUD_RATE = 115200
ser = None

# --- DATABASE LOGGING FUNCTIONS ---
def log_message_to_supabase(data: dict):
    """
    Inserts a chat message into the 'messages' table only if it's complete.
    """
    try:
        message_content = data.get('message', {})
        
        if isinstance(message_content, str):
            try:
                message_content = json.loads(message_content)
            except json.JSONDecodeError:
                message_content = {} # Treat as invalid if not proper JSON

        # **STRICT CHECK:** Only proceed if we have a dict with both username and message.
        if isinstance(message_content, dict) and message_content.get('username') and message_content.get('message'):
            payload = {
                'uuid': data.get('uuid'),
                'from_node': data.get('from_node'),
                'username': message_content.get('username'),
                'message': message_content.get('message')
            }
            supabase.table('messages').insert(payload).execute()
        else:
            # This is expected for sensor data that was misidentified. We can suppress this message.
            # print("INFO: Skipping incomplete message upload.")
            pass

    except Exception as e:
        print(f"DB_ERROR (message): {e}")


def log_sensor_data_to_supabase(data: dict):
    """
    Inserts sensor readings if at least one value is present.
    """
    try:
        # **CHECK:** Only proceed if at least one sensor key ('moisture' or 'pressure') exists.
        if 'moisture' in data or 'pressure' in data:
            payload = {
                'soil_moisture': data.get('moisture'),      # Safely gets value or None
                'pore_water_pressure': data.get('pressure') # Safely gets value or None
            }
            supabase.table('real_sensor_data').insert(payload).execute()
        else:
            print("INFO: Skipping sensor data upload, no valid fields found.")
        
    except Exception as e:
        print(f"DB_ERROR (sensor): {e}")


# --- CORE LOGIC ---
def reader_thread():
    """Reads from serial port, prints, and logs to database."""
    global ser
    while True:
        if ser and ser.is_open:
            try:
                line = ser.readline().decode('utf-8').strip()
                if line:
                    try:
                        data = json.loads(line)
                        print_formatted_data(data)
                        
                        # Differentiate based on the 'type' field OR the presence of sensor keys.
                        if data.get('type') == 'sensors' or 'moisture' in data or 'pressure' in data:
                            log_sensor_data_to_supabase(data)
                        else:
                            log_message_to_supabase(data)
                            
                    except json.JSONDecodeError:
                        print(f"RAW: {line}")
            except (serial.SerialException, OSError):
                print("Serial connection lost. Attempting to reconnect...")
                if ser:
                    ser.close()
                time.sleep(2)
        else:
            try:
                ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
                print("Reconnected to serial port.")
            except serial.SerialException:
                time.sleep(2)

def print_formatted_data(data: dict):
    """Prints incoming data in a nice, color-coded format."""
    from_node = data.get('from_node', 'Unknown Node')
    
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    ENDC = '\033[0m'

    print("-" * 50)
    
    # Use the same robust check here to ensure console output is correct.
    if data.get('type') == 'sensors' or 'moisture' in data or 'pressure' in data:
        moisture = data.get('moisture')
        pressure = data.get('pressure')
        print(f"{OKBLUE}📊 Sensor Packet from: {HEADER}{from_node}{ENDC}")
        if moisture is not None:
            # Ensure moisture is a number before formatting
            try:
                print(f"   ├── Moisture: {float(moisture):.2f}%")
            except (ValueError, TypeError):
                print(f"   ├── Moisture: {moisture} (Invalid Value)")
        if pressure is not None:
            # Ensure pressure is a number before formatting
            try:
                print(f"   └── Pressure: {float(pressure):.2f}")
            except (ValueError, TypeError):
                 print(f"   └── Pressure: {pressure} (Invalid Value)")
    else:
        message_content = data.get('message', {})
        if isinstance(message_content, str):
            try:
                message_content = json.loads(message_content)
            except json.JSONDecodeError:
                message_content = {'username': 'Unknown', 'message': message_content}

        username = message_content.get('username', 'Unknown User')
        message = message_content.get('message', '(empty message)')
        print(f"{OKGREEN}✉️  Message from: {HEADER}{username}{ENDC} {OKBLUE}(via {from_node}){ENDC}")
        print(f"   └── \"{message}\"")


if __name__ == "__main__":
    print("Starting Raspberry Pi Logger & Supabase Uploader...")
    
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
    except serial.SerialException as e:
        print(f"Error: Could not open serial port {SERIAL_PORT}.")
        sys.exit(1)

    thread_read = threading.Thread(target=reader_thread, daemon=True)
    thread_read.start()
    
    while True:
        try:
            time.sleep(1)
        except KeyboardInterrupt:
            print("\nExiting...")
            if ser:
                ser.close()
            sys.exit(0)
