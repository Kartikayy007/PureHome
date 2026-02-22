import Foundation

struct SensorReading: Codable, Identifiable {
    var id: UUID { UUID() }
    let deviceId: String
    let pm2_5: Double
    let pm10: Double
    let co2: Double
    let temperature: Double
    let humidity: Double
    let timestamp: Date
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case pm2_5
        case pm10
        case co2
        case temperature
        case humidity
        case timestamp
        case status
    }
}
