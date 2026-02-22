import Combine
import CoreBluetooth
import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var rooms: [RoomViewModel] = []

    @AppStorage("isMockMode") var isMockMode: Bool = true {
        didSet {
            setupRooms()
        }
    }

    init() {
        setupRooms()
    }

    private func setupRooms() {
        let living = Device(
            id: "room_living", name: "Living Room", status: .offline, lastReading: nil)
        let bedroom = Device(
            id: "room_bedroom", name: "Bedroom", status: .offline, lastReading: nil)
        let kitchen = Device(
            id: "room_kitchen", name: "Kitchen", status: .offline, lastReading: nil)

        rooms = [
            RoomViewModel(device: living, isMock: isMockMode),
            RoomViewModel(device: bedroom, isMock: isMockMode),
            RoomViewModel(device: kitchen, isMock: isMockMode),
        ]
    }

    func refreshAll() {
        for room in rooms {
            room.reconnect()
        }
    }

    func addBLERoom(peripheral: CBPeripheral, displayName: String) {
        let deviceID = peripheral.identifier.uuidString

        guard !rooms.contains(where: { $0.device.id == deviceID }) else { return }

        let device = Device(id: deviceID, name: displayName, status: .syncing, lastReading: nil)
        let bleService = BLEDeviceService(deviceID: deviceID, peripheralUUID: peripheral.identifier)

        let roomVM = RoomViewModel(device: device, bleService: bleService)
        bleService.connectDirectly(to: peripheral)

        DispatchQueue.main.async {
            self.rooms.insert(roomVM, at: 0)
        }
    }
}
