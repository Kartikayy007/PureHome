import Combine
import CoreBluetooth
import SwiftUI

class BLEScannerViewModel: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var peripheralNames: [UUID: String] = [:]
    @Published var isScanning = false
    @Published var bluetoothState: CBManagerState = .unknown

    private var centralManager: CBCentralManager?

    func startScan() {
        discoveredPeripherals.removeAll()
        peripheralNames.removeAll()

        centralManager = CBCentralManager(delegate: self, queue: .main)
        isScanning = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self] in
            self?.stopScan()
        }
    }

    func stopScan() {
        isScanning = false
        if centralManager?.state == .poweredOn {
            centralManager?.stopScan()
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
        print("BLE: State → \(central.state.rawValue)")

        switch central.state {
        case .poweredOn:

            central.scanForPeripherals(
                withServices: nil,
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
            print("BLE: Scan started.")
        case .poweredOff:
            print("BLE: Bluetooth is OFF — turn on Bluetooth and try again.")
            isScanning = false
        case .unauthorized:
            print("BLE: Not authorized — check Privacy > Bluetooth in Settings.")
            isScanning = false
        default:
            print("BLE: Waiting for BT state (\(central.state.rawValue))...")
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let deviceName =
            peripheral.name
            ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String
            ?? "Unknown Device"

        print("BLE: Found '\(deviceName)' [\(peripheral.identifier.uuidString)] RSSI:\(RSSI)")

        DispatchQueue.main.async {
            if !self.discoveredPeripherals.contains(where: {
                $0.identifier == peripheral.identifier
            }) {
                self.discoveredPeripherals.append(peripheral)
                self.peripheralNames[peripheral.identifier] = deviceName
            }
        }
    }
}
