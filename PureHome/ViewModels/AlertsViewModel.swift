import Foundation
import Combine

class AlertsViewModel: ObservableObject {
    @Published var alerts: [Alert] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        DataStore.shared.$alerts
            .receive(on: DispatchQueue.main)
            .assign(to: \.alerts, on: self)
            .store(in: &cancellables)
    }
    
    func filter(by room: String?) -> [Alert] {
        guard let room = room else { return alerts }
        return alerts.filter { $0.roomName == room }
    }
}
