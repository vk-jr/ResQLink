#include <WiFi.h>
#include <esp_now.h>
#include <ArduinoJson.h>
#include <list> 

// CONFIGURATION
#define CHANNEL 1

// GLOBALS
std::list<String> recentUuids; 
const int MAX_UUIDS = 20;
uint8_t broadcastAddress[] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
char jsonData[256];

// Function to generate a random UUID for messages from the Pi
String generateUuid() {
  char uuidStr[37];
  sprintf(uuidStr, "%04x%04x-%04x-%04x-%04x-%04x%04x%04x",
          random(0, 0xffff), random(0, 0xffff),
          random(0, 0xffff),
          random(0, 0x0fff) | 0x4000,
          random(0, 0x3fff) | 0x8000,
          random(0, 0xffff), random(0, 0xffff), random(0, 0xffff));
  return String(uuidStr);
}


// This is the main callback function
void OnDataRecv(const esp_now_recv_info * info, const uint8_t *incomingData, int len) {
  StaticJsonDocument<256> doc;
  if (deserializeJson(doc, incomingData, len) != DeserializationError::Ok) {
    Serial.println("deserializeJson() failed");
    return;
  }

  // Deduplication check
  String uuid = doc["uuid"];
  for (const String &id : recentUuids) {
    if (id == uuid) { return; }
  }
  recentUuids.push_front(uuid);
  if (recentUuids.size() > MAX_UUIDS) { recentUuids.pop_back(); }

  // --- THIS IS THE CORE LOGIC ---
  
  // 1. Forward to Raspberry Pi via Serial (Task A)
  serializeJson(doc, Serial);
  Serial.println();

  // 2. Rebroadcast to all other nodes via ESP-NOW (Task B)
  // *** THIS IS THE CRITICAL LINE THAT ENABLES THE FEATURE ***
  esp_now_send(broadcastAddress, (uint8_t *)incomingData, len);
}

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();

  if (esp_now_init() != ESP_OK) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }

  esp_now_register_recv_cb(OnDataRecv);
  Serial.println("ESP32 Core Relay Initialized with Rebroadcast.");
}

void loop() {
  // This part handles sending messages FROM the Pi, if you type in the terminal
  if (Serial.available() > 0) {
    String messageFromPi = Serial.readStringUntil('\n');
    messageFromPi.trim();

    if (messageFromPi.length() > 0) {
      StaticJsonDocument<256> doc;
      doc["uuid"] = generateUuid();
      doc["from_node"] = "RaspberryPi";
      doc["username"] = "Admin";
      doc["message"] = messageFromPi;

      size_t len = serializeJson(doc, jsonData);
      esp_now_send(broadcastAddress, (uint8_t *)jsonData, len);
    }
  }
}
