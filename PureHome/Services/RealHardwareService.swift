import Foundation
import Combine

class RealHardwareService: IoTDeviceConnectable {
    let deviceID: String
    let urlString: String
    
    var deviceType: DeviceConnectionType {
        .webSocket(url: URL(string: urlString) ?? URL(string: "ws://localhost")!)
    }
    
    private let readingsSubject = PassthroughSubject<SensorReading, Never>()
    private let statusSubject = CurrentValueSubject<ConnectionStatus, Never>(.offline)
    
    var sensorData: AnyPublisher<SensorReading, Never> {
        readingsSubject.eraseToAnyPublisher()
    }
    
    var statusPublisher: AnyPublisher<ConnectionStatus, Never> {
        statusSubject.eraseToAnyPublisher()
    }
    
    init(deviceID: String, urlString: String) {
        self.deviceID = deviceID
        self.urlString = urlString
    }
    
    func connect() {
        statusSubject.send(.syncing)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.statusSubject.send(.online)
        }
    }
    
    func disconnect() {
        statusSubject.send(.offline)
    }
}
