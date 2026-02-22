import SwiftUI

struct AlertsView: View {
    @StateObject private var viewModel = AlertsViewModel()
    @State private var selectedRoom: String? = nil
    
    let rooms = ["All", "Living Room", "Bedroom", "Kitchen"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "f9f9fe")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Filter by Room:")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "40493d"))
                        
                        Spacer()
                        
                        Menu {
                            ForEach(rooms, id: \.self) { room in
                                Button(action: {
                                    selectedRoom = room == "All" ? nil : room
                                }) {
                                    Text(room)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedRoom ?? "All Rooms")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "0d631b"))
                                Image(systemName: "chevron.down")
                                    .foregroundColor(Color(hex: "0d631b"))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(hex: "0d631b").opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filter(by: selectedRoom)) { alert in
                                AlertCard(alert: alert)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Alerts Log")
        }
    }
}

struct AlertCard: View {
    let alert: Alert
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(alert.severity == .critical ? Color.red.opacity(0.1) : Color.orange.opacity(0.1))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: alert.severity == .critical ? "exclamationmark.triangle.fill" : "bell.fill")
                        .foregroundColor(alert.severity == .critical ? .red : .orange)
                        .font(.system(size: 20, weight: .medium))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "1a1c1f"))
                
                Text("\(alert.roomName) - \(alert.message)")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color(hex: "40493d"))
                    .lineLimit(2)
                
                Text(alert.timestamp, style: .time)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
            Spacer()
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 40, x: 0, y: 20)
    }
}
