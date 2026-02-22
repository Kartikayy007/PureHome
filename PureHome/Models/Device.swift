import Foundation

enum ConnectionStatus: String, Codable {
    case online
    case offline
    case syncing
}

struct Device: Identifiable, Equatable {
    let id: String
    var name: String
    var status: ConnectionStatus
    var lastReading: SensorReading?
    
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.id == rhs.id && lhs.status == rhs.status && lhs.lastReading?.timestamp == rhs.lastReading?.timestamp
    }
}
