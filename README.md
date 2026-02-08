# PureSense: Smart Toilet Management System

An IoT-enabled restroom monitoring system integrating ESP32 microcontroller, multiple sensors, Firebase cloud database, and Flutter mobile application for real-time facility management and automation.

## Overview

Developed as a project for the Embedded Systems Laboratory and Internet of Things (IoT) courses in 2024, PureSense addresses public restroom hygiene and maintenance challenges through automated monitoring and control. The system combines embedded hardware design with cloud-based IoT infrastructure to create a comprehensive solution for facility management in high-traffic areas. Aligned with UN Sustainable Development Goals (SDGs) 3, 6, 11, and 12, the project emphasizes sustainability, efficient resource management, and improved public health outcomes through real-time data analytics and automated responses.

## Features

- **Automated Flushing**: Color sensor detects waste presence and triggers servo-controlled flushing mechanism automatically
- **Toilet Paper Level Monitoring**: Ultrasonic sensor (HC-SR04) measures supply levels and provides status updates via LED indicators and mobile app
- **Occupancy Detection**: PIR motion sensor tracks restroom usage with real-time status display (Occupied/Vacant)
- **Air Quality Management**: MQ-135 gas sensor monitors air quality parameters; DHT22 sensor controls humidity levels via ultrasonic mist maker
- **Real-Time Cloud Integration**: Firebase Realtime Database enables seamless data transmission and synchronization
- **Mobile Application**: Flutter-based app provides live monitoring, notifications, alerts, and usage analytics for users and maintenance personnel
- **Dual-Core Processing**: ESP32 microcontroller architecture dedicates one core to sensor data processing and another to wireless communication

## Limitations

- **Ultrasonic Sensor Accuracy**: Measurement errors up to 35% in confined spaces due to signal reflections from reflective surfaces within the toilet paper container
- **False Occupancy Detection**: PIR sensor generated false positive signals at approximately 22% frequency due to environmental factors (air movements, electromagnetic interference, proximity to electronic components)
- **Sensor Calibration Requirements**: Environmental factors in prototype design caused fluctuations in sensor data, requiring further optimization and calibration
- **Platform Constraints**: Limited to capabilities of ESP32 microcontroller and selected sensor modules compared to more advanced embedded platforms

## System Requirements

- **Hardware**: ESP32 microcontroller (dual-core), HC-SR04 ultrasonic sensor, PIR motion sensor, MQ-135 gas sensor, DHT22 temperature/humidity sensor, color sensor, servo motors, ultrasonic mist maker
- **Cloud Platform**: Firebase Realtime Database, Firebase Authentication
- **Mobile Application**: Flutter framework for cross-platform deployment
- **Connectivity**: Wi-Fi network for cloud communication
