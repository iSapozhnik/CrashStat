/*
 * HTTP Client GET Request
 * Copyright (c) 2018, circuits4you.com
 * All rights reserved.
 * https://circuits4you.com 
 * Connects to WiFi HotSpot. */

#include <Timer.h>
#include <ESP8266WiFi.h>
#include <DNSServer.h>
#include <WiFiClient.h> 
#include <ESP8266WebServer.h>
#include <ESP8266HTTPClient.h>
#include <WiFiManager.h>
#include "ArduinoJson.h"

#include <MD_MAX72xx.h>
#include <MD_Parola.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <Fonts/FreeSans9pt7b.h>
#include <ImagesAdafruit.h>


#define OLED_RESET LED_BUILTIN  //4
Adafruit_SSD1306 oled(OLED_RESET);

#if (SSD1306_LCDHEIGHT != 32)
#error("Height incorrect, please fix Adafruit_SSD1306.h!");
#endif

#define SCREEN_WIDTH                128
#define MENU_SIZE                   32
#define TOP_TEXT_POS                6
#define MIDDLE_TEXT_POS             10
#define BOTTOM_TEXT_POS             19
#define BOTTOM_RIGHT_ICON_WIDTH     16
#define BOTTOM_RIGHT_ICON_HEIGHT    13

#define MAX_DEVICES 4
#define HARDWARE_TYPE MD_MAX72XX::FC16_HW

#define  CLK_PIN   D5 // or SCK
#define DATA_PIN  D7 // or MOSI
#define CS_PIN    D8 // or SS

#define SCROLL_SPEED 40

Timer t;

MD_Parola P = MD_Parola(HARDWARE_TYPE, CS_PIN, MAX_DEVICES);
#define  BUF_SIZE  75  // Maximum of 75 characters
char currMessage[BUF_SIZE] = { "Brainy-Bits" };  // used to hold current message

bool newMessageAvailable = true;

//=======================================================================
//                    Power on setup
//=======================================================================

void setup() {
  
  oled.begin(SSD1306_SWITCHCAPVCC, 0x3C);
  oled.setTextColor(WHITE);
  oled.clearDisplay();
  oled.display();

  oled.setTextSize(1);
  oled.setFont();
  
  Serial.begin(115200);

  P.begin();
  P.setIntensity(1);
  P.displayText("Connecting...", PA_LEFT, SCROLL_SPEED, 50, PA_SCROLL_LEFT, PA_SCROLL_LEFT);

  WiFiManager wifiManager;
//  wifiManager.resetSettings();
  oled.setCursor(0,0);
  oled.println("Connecting...");
  oled.display();
  delay(1000);
  wifiManager.setAPCallback(configModeCallback);

  if(!wifiManager.autoConnect("CrashStats", "11111111")) {
    Serial.println("failed to connect and hit timeout");
    oled.println("failed to connect and hit timeout");
    oled.display();
    //reset and try again, or maybe put it to deep sleep
    ESP.reset();
    delay(1000);
  }

  //If connection successful show IP address in serial monitor
  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(WiFi.SSID());
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());  //IP address assigned to your ESP

  oled.clearDisplay();
  oled.setCursor(0,0);
  oled.println("Connected to: ");
  oled.println(WiFi.SSID());
  oled.println("Loading crash statistics...");
  oled.display();
  delay(1500);
  
  t.every(60*1000, getCrashData);
  getCrashData();

}

//=======================================================================
//                    Main Program Loop
//=======================================================================
void loop() {
  if (WiFi.status() == WL_CONNECTED) { //Check WiFi connection status
    if (P.displayAnimate()) { // If finished displaying message
      P.displayReset();  // Reset and display it again
    }
    t.update();
  }
}

void configModeCallback (WiFiManager *myWiFiManager) {
  String message = "Entered config mode.";
  String ip = "IP: " + String(WiFi.softAPIP());
  String ssid = "SSID: " + String(myWiFiManager->getConfigPortalSSID());
  Serial.println(message);
  Serial.println(ip);
  Serial.println(WiFi.softAPIP());

  oled.clearDisplay();
  oled.setCursor(0,0);
  oled.println(message);
  oled.print("IP: ");
  oled.println(WiFi.softAPIP());
  oled.println(ssid);
  oled.println("PASS: 11111111");
  oled.display();
}

void getCrashData() {
  P.displayClear();
  oled.clearDisplay();
  oled.setCursor(0,0);
  HTTPClient http;  //Declare an object of class HTTPClient

  String url = "http://vapor-crashstat.herokuapp.com/crash";
  http.begin(url);  //Specify request destination
  int httpCode = http.GET();                                                                  //Send the request
  if (httpCode > 0) { //Check the returning code
    String payload = http.getString();   //Get the request response payload

    char json[50];
    const size_t bufferSize = JSON_OBJECT_SIZE(2) + 20;
    DynamicJsonBuffer jsonBuffer(bufferSize);

//    const char* json = "{\"ios\":4,\"android\":0}";
    payload.toCharArray(json, 50);

    JsonObject& root = jsonBuffer.parseObject(json);
    
    int ios = root["ios"]; // 4
    int android = root["android"]; // 0
    
    Serial.println(payload);                     //Print the response payload
//    oled.setTextSize(1);
//    oled.println("Status: OK");
//    oled.display();
    oled.setTextSize(2);
    oled.print("iOS:");
    oled.println(String(ios));
    oled.print("And:");
    oled.println(String(android));
    oled.display();
    String text = "iOS:"+String(ios)+" Android:"+String(android);

    char curMessage[512];

    sprintf(curMessage, "Crashes: iOS: %d               Android: %d", ios, android);
    P.displayText(curMessage, PA_LEFT, SCROLL_SPEED, 50, PA_SCROLL_LEFT, PA_SCROLL_LEFT);

//    scrollText(copy);
  } else {
    Serial.printf("[HTTP] GET... failed, error: %s\n", http.errorToString(httpCode).c_str());
    oled.println("Status: Error");
    oled.display();
  }

 
  http.end();   //Close connection
}
//=======================================================================
