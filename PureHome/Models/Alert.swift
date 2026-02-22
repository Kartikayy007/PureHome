import Foundation

enum AlertSeverity: String, Codable {
    case warning
    case critical
    case info
}

struct Alert: Identifiable, Codable {
    let id: UUID
    let deviceID: String
    let roomName: String
    let title: String
    let message: String
    let timestamp: Date
    let severity: AlertSeverity
    let metric: String
    let value: String
    
    init(id: UUID = UUID(), deviceID: String, roomName: String, title: String, message: String, timestamp: Date = Date(), severity: AlertSeverity, metric: String, value: String) {
        self.id = id
        self.deviceID = deviceID
        self.roomName = roomName
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.severity = severity
        self.metric = metric
        self.value = value
    }
}
