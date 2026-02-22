import Combine
import CoreBluetooth
import Foundation

class BLEDeviceService: NSObject, IoTDeviceConnectable, CBCentralManagerDelegate,
    CBPeripheralDelegate
{
    let deviceID: String
    let peripheralUUID: UUID

    var deviceType: DeviceConnectionType {
        .ble(peripheralUUID: peripheralUUID)
    }

    private let sensorSubject = PassthroughSubject<SensorReading, Never>()
    private let statusSubject = CurrentValueSubject<ConnectionStatus, Never>(.offline)

    var sensorData: AnyPublisher<SensorReading, Never> {
        sensorSubject.eraseToAnyPublisher()
    }

    var statusPublisher: AnyPublisher<ConnectionStatus, Never> {
        statusSubject.eraseToAnyPublisher()
    }

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?

    let airQualityServiceUUID = CBUUID(string: "FFE0")
    let dataCharUUID = CBUUID(string: "FFE1")

    init(deviceID: String, peripheralUUID: UUID) {
        self.deviceID = deviceID
        self.peripheralUUID = peripheralUUID
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    func connect() {
        statusSubject.send(.syncing)

        if centralManager.state == .poweredOn {
            startScanning()
        }
    }

    func disconnect() {
        if let p = peripheral {
            centralManager.cancelPeripheralConnection(p)
        }
        statusSubject.send(.offline)
    }

    func connectDirectly(to knownPeripheral: CBPeripheral) {
        self.peripheral = knownPeripheral
        self.peripheral?.delegate = self
        statusSubject.send(.syncing)
        centralManager.stopScan()
        centralManager.connect(knownPeripheral, options: nil)
    }

    private func startScanning() {

        centralManager.scanForPeripherals(withServices: [airQualityServiceUUID], options: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            if statusSubject.value == .syncing {
                startScanning()
            }
        case .poweredOff:
            statusSubject.send(.offline)
        default:
            break
        }
    }

    func centralManager(
        _ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any], rssi RSSI: NSNumber
    ) {

        if peripheral.identifier == peripheralUUID {
            self.peripheral = peripheral
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        statusSubject.send(.online)
        self.peripheral?.delegate = self

        self.peripheral?.discoverServices([airQualityServiceUUID])
    }

    func centralManager(
        _ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?
    ) {
        statusSubject.send(.offline)
    }

    func centralManager(
        _ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?
    ) {
        statusSubject.send(.offline)

        if statusSubject.value != .offline {
            connect()
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services where service.uuid == airQualityServiceUUID {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?
    ) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {

                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        guard let data = characteristic.value, data.count >= 10 else { return }

        let pm25 = Double(UInt16(data[0]) | UInt16(data[1]) << 8)
        let pm10 = Double(UInt16(data[2]) | UInt16(data[3]) << 8)
        let co2 = Double(UInt16(data[4]) | UInt16(data[5]) << 8)
        let temp = Double(UInt16(data[6]) | UInt16(data[7]) << 8) / 10.0
        let hum = Double(UInt16(data[8]) | UInt16(data[9]) << 8)

        let reading = SensorReading(
            deviceId: deviceID,
            pm2_5: pm25,
            pm10: pm10,
            co2: co2,
            temperature: temp,
            humidity: hum,
            timestamp: Date(),
            status: "active_ble"
        )

        sensorSubject.send(reading)
    }
}
