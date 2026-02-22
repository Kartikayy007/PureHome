import Foundation

enum DeviceConnectionType {
    case mock
    case webSocket(url: URL)
    case ble(peripheralUUID: UUID)
}
