import Foundation
import Combine

class MockSensorService: IoTDeviceConnectable {
    let deviceID: String
    private var webSocketTask: URLSessionWebSocketTask?
    
    var deviceType: DeviceConnectionType { .mock }
    
    private let readingsSubject = PassthroughSubject<SensorReading, Never>()
    private let statusSubject = CurrentValueSubject<ConnectionStatus, Never>(.offline)
    
    var sensorData: AnyPublisher<SensorReading, Never> {
        readingsSubject.eraseToAnyPublisher()
    }
    
    var statusPublisher: AnyPublisher<ConnectionStatus, Never> {
        statusSubject.eraseToAnyPublisher()
    }
    
    init(deviceID: String) {
        self.deviceID = deviceID
    }
    
    func connect() {
        guard webSocketTask == nil else { return }
        
        statusSubject.send(.syncing)
        guard let url = URL(string: "ws://192.168.1.15:8080") else { return }
        
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        statusSubject.send(.online)
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        statusSubject.send(.offline)
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error)
                self.statusSubject.send(.offline)
                self.webSocketTask = nil
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.connect()
                }
                
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleText(text)
                case .data(let data):
                    self.handleData(data)
                @unknown default:
                    break
                }
                self.receiveMessage()
            }
        }
    }
    
    private func handleText(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        handleData(data)
    }
    
    private func handleData(_ data: Data) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let reading = try decoder.decode(SensorReading.self, from: data)
            if reading.deviceId == self.deviceID {
                DispatchQueue.main.async {
                    self.readingsSubject.send(reading)
                    self.statusSubject.send(reading.status == "online" ? .online : .offline)
                }
            }
        } catch {
            print(error)
        }
    }
}
