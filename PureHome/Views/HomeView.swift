import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "f9f9fe")
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(viewModel.rooms) { roomVM in
                            NavigationLink(destination: RoomDetailView(viewModel: roomVM)) {
                                RoomCardView(viewModel: roomVM)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        SensorDeepDiveView(viewModel: viewModel)
                    }
                    .padding(24)
                }
                .navigationTitle("PureHome")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: AddDeviceView(homeViewModel: viewModel)) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "0d631b"))
                        }
                    }
                }
                .refreshable {
                    viewModel.refreshAll()
                }
            }
        }
    }
}

struct SensorDeepDiveView: View {
    @ObservedObject var viewModel: HomeViewModel

    private var avgPM: Double {
        viewModel.rooms.compactMap { $0.device.lastReading.map { Double($0.pm2_5) } }.average()
    }

    private var avgTemp: Double {
        viewModel.rooms.compactMap { $0.device.lastReading.map { Double($0.temperature) } }
            .average()
    }

    private var avgHum: Double {
        viewModel.rooms.compactMap { $0.device.lastReading.map { Double($0.humidity) } }.average()
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Sensor Deep Dive")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "1a1c1f"))
                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.top, 16)

            VStack(spacing: 24) {
                SensorRow(
                    iconName: "circles.hexagonpath.fill",
                    iconColor: Color(hex: "0d631b"),
                    title: "PM 2.5 Particles",
                    subtitle: "Fine inhalable particles",
                    value: String(format: "%.1f", avgPM),
                    unit: "µg/m³"
                )

                SensorRow(
                    iconName: "thermometer",
                    iconColor: Color(hex: "0d631b"),
                    title: "Temperature",
                    subtitle: "Current room climate",
                    value: String(format: "%.1f", avgTemp),
                    unit: "°C"
                )

                SensorRow(
                    iconName: "drop.fill",
                    iconColor: Color(hex: "0d631b"),
                    title: "Humidity",
                    subtitle: "Water vapor density",
                    value: String(format: "%.0f", avgHum),
                    unit: "%"
                )
            }
            .padding(24)
            .background(Color(hex: "f3f3f8"))
            .cornerRadius(24)
        }
    }
}

struct SensorRow: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let value: String
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: iconName)
                            .foregroundColor(iconColor)
                            .font(.system(size: 20, weight: .medium))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "1a1c1f"))
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: "40493d"))
                }
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "1a1c1f"))
                Text(unit)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "40493d"))
            }
        }
    }
}

extension Array where Element == Double {
    func average() -> Double {
        if isEmpty { return 0.0 }
        return reduce(0, +) / Double(count)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
