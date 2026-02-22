import Foundation

class SensorFactory {
    static func createService(for deviceID: String, isMock: Bool) -> IoTDeviceConnectable {
        if isMock {
            return MockSensorService(deviceID: deviceID)
        } else {
            let userIP = UserDefaults.standard.string(forKey: "hardwareDeviceURL") ?? ""
            return RealHardwareService(deviceID: deviceID, urlString: userIP)
        }
    }
}
