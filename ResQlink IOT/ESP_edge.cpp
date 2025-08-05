#include <WiFi.h>
#include <esp_now.h>
#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>
#include <Wire.h>
#include <Adafruit_BMP085.h>

// CONFIGURATION
#define CHANNEL 1
const char* ssid = "ESP32-Node";
const char* password = "password123";
const char* NODE_ID = "esp32-1-A";

// *** REAL SENSOR CONFIGURATION ***
#define SENSOR_PIN 34      // A0 from YL-69 to GPIO34
const int dryValue = 3600;   // Dry soil reading (adjust based on your tests)
const int wetValue = 1300;   // Wet soil reading (adjust based on your tests)
const int numSamples = 10;   // For averaging

// GLOBALS
uint8_t broadcastAddress[] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
AsyncWebServer server(80);
AsyncEventSource events("/events");
Adafruit_BMP085 bmp; // Create an object for the pressure sensor
bool bmp_found = false; // Flag to track if the sensor was found

unsigned long lastSensorReadTime = 0;
const unsigned long sensorReadInterval = 10000; // 10 seconds

// *** SENSOR FUNCTIONS ***
float readAverageMoisture() {
  long total = 0;
  for (int i = 0; i < numSamples; i++) {
    total += analogRead(SENSOR_PIN);
    delay(50); 
  }
  return total / float(numSamples);
}

float calculateMoisturePercent(int rawValue) {
  rawValue = constrain(rawValue, wetValue, dryValue);
  float percent = map(rawValue, dryValue, wetValue, 0, 100);
  return constrain(percent, 0.0, 100.0);
}

// Function to generate a random UUID
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

void OnDataRecv(const esp_now_recv_info * info, const uint8_t *incomingData, int len) {
  char buffer[len + 1];
  memcpy(buffer, incomingData, len);
  buffer[len] = 0;
  events.send(buffer, "message", millis());
}

void sendJsonViaEspNow(JsonDocument& doc) {
  char buffer[256];
  size_t len = serializeJson(doc, buffer);
  esp_now_send(broadcastAddress, (uint8_t *)buffer, len);
}

void setup() {
  Serial.begin(115200);
  Serial.println("\n\nBooting Edge Node (Dual Sensor)...");

  // Initialize the I2C bus for the BMP180 sensor
  // Uses default pins (SDA=21, SCL=22)
  if (!bmp.begin()) {
    Serial.println("Could not find a valid BMP180 sensor, check wiring!");
    bmp_found = false;
  } else {
    Serial.println("BMP180 sensor found!");
    bmp_found = true;
  }
  
  WiFi.mode(WIFI_AP_STA);
  WiFi.softAP(ssid, password);
  
  if (esp_now_init() != ESP_OK) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }

  esp_now_peer_info_t peerInfo = {};
  memcpy(peerInfo.peer_addr, broadcastAddress, 6);
  peerInfo.channel = CHANNEL;
  peerInfo.encrypt = false;
  esp_now_add_peer(&peerInfo);
  esp_now_register_recv_cb(OnDataRecv);

  // This handler for chat messages is unchanged
  server.on("/send", HTTP_POST, [](AsyncWebServerRequest *request) {}, NULL, [](AsyncWebServerRequest *request, uint8_t *data, size_t len, size_t index, size_t total) {
    StaticJsonDocument<256> receivedJson;
    if (deserializeJson(receivedJson, data, len) == DeserializationError::Ok) {
        StaticJsonDocument<256> outgoingJson;
        outgoingJson["uuid"] = generateUuid();
        outgoingJson["from_node"] = NODE_ID;
        outgoingJson["message"] = receivedJson; 
        sendJsonViaEspNow(outgoingJson);
    }
    request->send(200, "text/plain", "OK");
  });

  server.addHandler(&events);
  server.begin();
  Serial.println("Edge Node Initialized. Web server running.");
}

void loop() {
  if (millis() - lastSensorReadTime > sensorReadInterval) {
    lastSensorReadTime = millis();
    Serial.println("Reading sensors...");

    // SOIL MOISTURE LOGIC
    float moisture;
    float averageRaw = readAverageMoisture();
    if (averageRaw < 100) {
        moisture = 0.0;
        Serial.println("Soil moisture dummy value (sensor disconnected?)");
    } else {
        moisture = calculateMoisturePercent(averageRaw);
    }

    // PORE WATER PRESSURE LOGIC
    float pressure;
    if (bmp_found) {
        // Read the real value from the sensor (in hPa)
        pressure = bmp.readPressure() / 100.0F;
    } else {
        pressure = 0.0;
        Serial.println("Pore water pressure is using dummy values");
    }

    // Create the JSON packet
    StaticJsonDocument<256> doc;
    doc["uuid"] = generateUuid();
    doc["from_node"] = NODE_ID;
    doc["type"] = "sensors";
    doc["moisture"] = moisture;
    doc["pressure"] = pressure;

    sendJsonViaEspNow(doc);
    Serial.printf("Sent data: Moisture=%.2f, Pressure=%.2f hPa\n", moisture, pressure);
  }
}
