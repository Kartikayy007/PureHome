import Combine
import Foundation

class RoomViewModel: ObservableObject, Identifiable {
    @Published var device: Device
    @Published var recentReadings: [SensorReading] = []

    private let service: IoTDeviceConnectable
    private var cancellables = Set<AnyCancellable>()

    var id: String { device.id }

    var currentAQI: Int {
        guard let reading = device.lastReading else { return 0 }
        return AQICalculator.calculate(pm25: reading.pm2_5)
    }

    var aqiCategory: AQICategory {
        return AQICalculator.category(for: currentAQI)
    }

    var dominantPollutant: String {
        return "PM2.5"
    }

    init(device: Device, isMock: Bool = true) {
        self.device = device
        self.service = SensorFactory.createService(for: device.id, isMock: isMock)
        setupSubscriptions()

        if isMock || !(self.service is BLEDeviceService) {
            self.service.connect()
        }
    }

    init(device: Device, bleService: IoTDeviceConnectable) {
        self.device = device
        self.service = bleService
        setupSubscriptions()

    }

    func toggleServiceMode(isMock: Bool) {
        service.disconnect()
    }

    func reconnect() {
        service.connect()
    }

    private func setupSubscriptions() {
        service.statusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.device.status = status
                if status == .offline {
                    self?.checkOfflineAlert()
                }
            }
            .store(in: &cancellables)

        service.sensorData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reading in
                guard let self = self else { return }
                self.device.lastReading = reading

                self.recentReadings.append(reading)
                if self.recentReadings.count > 12 {
                    self.recentReadings.removeFirst()
                }

                self.checkThresholds(reading)
            }
            .store(in: &cancellables)
    }

    private func checkThresholds(_ reading: SensorReading) {
        let pmLimit = pm25Threshold
        let co2Limit = co2Threshold

        if reading.pm2_5 > pmLimit {
            triggerAlert(
                title: "Poor Air Quality",
                message: "\(device.name) PM2.5 is high (\(reading.pm2_5)).", metric: "PM2.5",
                value: "\(reading.pm2_5)", severity: .critical)
        }

        if reading.co2 > co2Limit {
            triggerAlert(
                title: "High CO2", message: "Ventilate \(device.name).", metric: "CO2",
                value: "\(reading.co2)", severity: .warning)
        }
    }

    private var pm25Threshold: Double {
        let key = "pm25Threshold"
        if UserDefaults.standard.object(forKey: key) == nil { return 100.0 }
        return UserDefaults.standard.double(forKey: key)
    }

    private var co2Threshold: Double {
        let key = "co2Threshold"
        if UserDefaults.standard.object(forKey: key) == nil { return 1000.0 }
        return UserDefaults.standard.double(forKey: key)
    }

    private var isNotificationsEnabled: Bool {
        let key = "notify_\(device.id)"
        if UserDefaults.standard.object(forKey: key) == nil { return true }
        return UserDefaults.standard.bool(forKey: key)
    }

    private func checkOfflineAlert() {
        triggerAlert(
            title: "Device Offline", message: "\(device.name) purifier disconnected.",
            metric: "Status", value: "Offline", severity: .warning)
    }

    private let alertCooldown: TimeInterval = 60
    private var lastAlertTime: [String: Date] = [:]

    private func triggerAlert(
        title: String, message: String, metric: String, value: String, severity: AlertSeverity
    ) {
        guard isNotificationsEnabled else { return }

        let now = Date()
        if let last = lastAlertTime[metric], now.timeIntervalSince(last) < alertCooldown {
            return
        }
        lastAlertTime[metric] = now

        let alert = Alert(
            deviceID: device.id, roomName: device.name, title: title, message: message,
            severity: severity, metric: metric, value: value)
        DataStore.shared.addAlert(alert)
        NotificationManager.shared.scheduleNotification(title: title, body: message)
    }
}
