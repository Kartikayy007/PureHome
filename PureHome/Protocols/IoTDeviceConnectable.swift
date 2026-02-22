import Foundation
import Combine

protocol IoTDeviceConnectable {
    var deviceID: String { get }
    var deviceType: DeviceConnectionType { get }
    var sensorData: AnyPublisher<SensorReading, Never> { get }
    var statusPublisher: AnyPublisher<ConnectionStatus, Never> { get }
    
    func connect()
    func disconnect()
}
