import Foundation
import Combine

class DataStore: ObservableObject {
    static let shared = DataStore()
    
    @Published var alerts: [Alert] = []
    
    private init() {
        loadData()
    }
    
    func addAlert(_ alert: Alert) {
        DispatchQueue.main.async {
            self.alerts.insert(alert, at: 0)
            self.saveData()
        }
    }
    
    private func saveData() {
        do {
            let data = try JSONEncoder().encode(alerts)
            UserDefaults.standard.set(data, forKey: "saved_alerts")
        } catch {}
    }
    
    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: "saved_alerts") else { return }
        do {
            let decoded = try JSONDecoder().decode([Alert].self, from: data)
            self.alerts = decoded
        } catch {}
    }
}
