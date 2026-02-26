<div align="center">

# 🌬️ PureHome

### Real-Time Air Quality Monitoring for iOS — Powered by BLE & WebSocket IoT

![Swift](https://img.shields.io/badge/Swift-5.9-F05138?style=for-the-badge&logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-17%2B-000000?style=for-the-badge&logo=apple&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-0071E3?style=for-the-badge&logo=apple&logoColor=white)
![CoreBluetooth](https://img.shields.io/badge/CoreBluetooth-BLE-00B2A9?style=for-the-badge&logo=bluetooth&logoColor=white)
![Combine](https://img.shields.io/badge/Combine-Reactive-FF6B6B?style=for-the-badge)
![WebSocket](https://img.shields.io/badge/WebSocket-Live%20Data-35B27E?style=for-the-badge)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-blueviolet?style=for-the-badge)

> A production-grade iOS app that connects to real IoT air quality sensors over **Bluetooth Low Energy** and **WebSocket**, parses live hardware telemetry, and visualizes PM2.5, PM10, CO2, Temperature & Humidity in real-time.

</div>

---

## 📸 What It Does

| Home Dashboard | Room Detail & Charts | Alerts & Thresholds | Add Device (BLE Scan) |
|:-:|:-:|:-:|:-:|
| Live AQI cards per room | Per-metric time-series charts | Smart push notifications | Real-time BLE peripheral scan |

---

## Screenshots

<div align="center">

| | | | |
|:---:|:---:|:---:|:---:|
| <img src="assets/Screenshot 2026-03-25 at 2.02.25 AM.png" width="200"> | <img src="assets/Screenshot 2026-03-25 at 4.39.38 PM.png" width="200"> | <img src="assets/Screenshot 2026-03-25 at 10.03.44 PM.png" width="200"> | <img src="assets/Screenshot 2026-03-25 at 10.03.58 PM.png" width="200"> |
| <img src="assets/Screenshot 2026-03-25 at 10.04.07 PM.png" width="200"> | <img src="assets/Screenshot 2026-03-25 at 10.04.30 PM.png" width="200"> | <img src="assets/Screenshot 2026-03-25 at 10.04.50 PM.png" width="200"> | <img src="assets/Screenshot 2026-03-25 at 10.05.03 PM.png" width="200"> |

</div>


---

## 🧠 Architecture

```
PureHome/
├── Models/              # SensorReading, Device, AQICategory, Alert, DeviceConnectionType
├── Protocols/           # IoTDeviceConnectable — unified BLE/WebSocket/Mock interface
├── Services/
│   ├── BLEDeviceService.swift        # CoreBluetooth Central Manager — FFE0/FFE1 UUIDs
│   ├── RealHardwareService.swift     # WebSocket live sensor stream
│   ├── MockSensorService.swift       # Simulate sensor data for UI dev
│   ├── SensorFactory.swift           # Factory — chooses service by connection type
│   ├── DataStore.swift               # In-memory alert log
│   └── NotificationManager.swift    # UNUserNotificationCenter scheduling
├── ViewModels/
│   ├── HomeViewModel.swift           # Room list + BLE room injection
│   ├── RoomViewModel.swift           # Per-room reactive pipeline (Combine)
│   ├── BLEScannerViewModel.swift     # Peripheral discovery (lazy CBCentralManager)
│   └── NewsViewModel.swift           # HN Algolia API for air quality news
├── Views/
│   ├── HomeView.swift                # Dashboard with AQI room cards
│   ├── RoomDetailView.swift          # Charts with threshold RuleMark overlays
│   ├── AddDeviceView.swift           # BLE scan + Wi-Fi entry
│   ├── AlertsView.swift              # Alert feed with severity badges
│   ├── SettingsView.swift            # Thresholds, notification toggles
│   └── NewsView.swift                # Live climate news feed
└── MockIOT/
    └── server.js                     # Node.js WebSocket server (IoT simulator)
```

---

## ⚙️ IoT Integration — How It Actually Works

### 🔵 Bluetooth Low Energy (CoreBluetooth)

PureHome implements a full **BLE Central Manager** pipeline from scratch:

```
User taps Scan
    └─▶ CBCentralManager created (lazy init — guarantees fresh poweredOn callback)
            └─▶ centralManagerDidUpdateState(.poweredOn) fires
                    └─▶ scanForPeripherals(withServices: nil)
                            └─▶ didDiscover peripheral → resolve name from advertisementData
                                    └─▶ User taps Connect
                                            └─▶ connectDirectly(to: peripheral) — NO second scan
                                                    └─▶ didConnect → discoverServices([FFE0])
                                                            └─▶ didDiscoverCharacteristics → setNotifyValue(FFE1)
                                                                    └─▶ didUpdateValueFor → parse 10-byte packet
                                                                            └─▶ SensorReading → Combine → UI
```

#### Raw Byte Parsing (Little Endian, 10-byte payload)
```swift
// Mac CLI sends 5 × UInt16 LE packed in 10 bytes
let pm25 = Double(UInt16(data[0]) | UInt16(data[1]) << 8)
let pm10 = Double(UInt16(data[2]) | UInt16(data[3]) << 8)
let co2  = Double(UInt16(data[4]) | UInt16(data[5]) << 8)
let temp = Double(UInt16(data[6]) | UInt16(data[7]) << 8) / 10.0   // ×10 scaling
let hum  = Double(UInt16(data[8]) | UInt16(data[9]) << 8)
```

**Service UUID:** `FFE0` | **Characteristic UUID:** `FFE1` | **Mode:** Notify

### 🟢 WebSocket (Wi-Fi / LAN)

```swift
// RealHardwareService streams JSON frames at 10s intervals
// { "device_id": "room_living", "pm2_5": 15, "pm10": 30, "co2": 412, ... }
```

Node.js mock server (`MockIOT/server.js`) simulates 3 rooms with realistic random variance, accessible at `ws://[MAC_IP]:8080`.

### 🔄 Unified Protocol

All three transport layers (`BLE`, `WebSocket`, `Mock`) conform to one protocol, making them fully interchangeable:

```swift
protocol IoTDeviceConnectable {
    var deviceType: DeviceConnectionType { get }
    var sensorData: AnyPublisher<SensorReading, Never> { get }
    var statusPublisher: AnyPublisher<ConnectionStatus, Never> { get }
    func connect()
    func disconnect()
}
```

---

## 📊 Data Model

```swift
struct SensorReading: Codable, Identifiable {
    let deviceId: String
    let pm2_5: Double        // µg/m³  — WHO threshold: 15
    let pm10: Double         // µg/m³
    let co2: Double          // ppm    — Alert threshold: 1000
    let temperature: Double  // °C
    let humidity: Double     // %RH
    let timestamp: Date
    let status: String
}
```

AQI calculation follows **US EPA breakpoints**, computed on-device from PM2.5 readings.

---

## 🔔 Smart Alerts

- **Threshold-based alerts** — user-configurable PM2.5 and CO2 limits per room
- **60-second cooldown** — prevents notification spam
- **Visual RuleMarks** — red threshold lines overlaid directly on Swift Charts
- **UNUserNotification** — native push notifications even when app is backgrounded
- **Per-room toggles** — granular notification control in Settings

---

## 🧩 Key Engineering Decisions

| Challenge | Solution |
|---|---|
| CBCentralManager race condition (state=0 on scan) | Lazy init of manager inside `startScan()` — fresh poweredOn callback every time |
| Mac advertises peripheral without name in packet | Resolve device name from `CBAdvertisementDataLocalNameKey` fallback |
| Two separate CBCentralManager instances disconnecting state | `connectDirectly(to:)` hands discovered `CBPeripheral` object directly — skips 2nd scan entirely |
| stopScan() API misuse crash | Guard against non-`.poweredOn` state before calling CoreBluetooth |
| Multi-transport architecture | `IoTDeviceConnectable` protocol + `SensorFactory` — swap BLE/WebSocket/Mock at runtime |
| Dark mode color inconsistency | Forced `.preferredColorScheme(.light)` globally to protect the "Pristine Cards" design system |

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| Reactive | Combine (`PassthroughSubject`, `CurrentValueSubject`, `AnyPublisher`) |
| BLE | CoreBluetooth (Central Manager, Peripheral Delegate) |
| Charts | Swift Charts with custom `RuleMark` threshold overlays |
| Networking | URLSession WebSocket / Node.js WS server |
| Notifications | UNUserNotificationCenter |
| Architecture | MVVM + Protocol-Oriented IoT Service Layer |
| IoT Simulator | Node.js (`ws` package) + Swift CLI (`CBPeripheralManager`) |
| Persistence | UserDefaults (settings), in-memory DataStore (alerts) |

---

## 🚀 Running the Project

### Prerequisites
- Xcode 15+
- iPhone with Bluetooth & Location Services enabled
- (Optional) Mac running the BLE CLI simulator or Node.js for WebSocket mode

### BLE Mode (Real Hardware Simulation)
```bash
# On Mac — run the Swift CLI BLE peripheral simulator
# It advertises as "PureHome Sensor" on SERVICE: FFE0 / CHAR: FFE1
swift run bluetest
```
On iPhone → open app → `+` → **Bluetooth** tab → **Scan** → tap **Connect**

### WebSocket Mode (Wi-Fi LAN)
```bash
cd MockIOT
npm install
node server.js   # Starts ws://0.0.0.0:8080
```
On iPhone → open app → `+` → **Wi-Fi** tab → enter `ws://[YOUR_MAC_IP]:8080`

### Mock Mode
Toggle the **Mock** switch in Settings — the app generates realistic simulated data locally, no hardware needed.

---

## 📐 Metrics Monitored

| Metric | Unit | Good | Moderate | Unhealthy |
|---|---|---|---|---|
| PM2.5 | µg/m³ | < 12 | 12–35 | > 35 |
| PM10 | µg/m³ | < 54 | 54–154 | > 154 |
| CO₂ | ppm | < 700 | 700–1000 | > 1000 |
| Temperature | °C | 18–24 | — | — |
| Humidity | %RH | 40–60 | — | — |

---

<div align="center">

Built with 🫁 for cleaner air — and to demonstrate full-stack IoT iOS engineering.

</div>
