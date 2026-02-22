import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
            .onAppear {
                NotificationManager.shared.requestAuthorization()
            }
    }
}
