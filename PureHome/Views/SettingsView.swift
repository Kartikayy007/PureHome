import SwiftUI

struct SettingsView: View {
    @AppStorage("isMockMode") var isMockMode: Bool = true
    @AppStorage("hardwareDeviceURL") var hardwareDeviceURL: String = ""
    
    @AppStorage("pm25Threshold") var pm25Threshold: Double = 100.0
    @AppStorage("co2Threshold") var co2Threshold: Double = 1000.0
    
    @AppStorage("notify_room_living") var notifyLiving: Bool = true
    @AppStorage("notify_room_bedroom") var notifyBedroom: Bool = true
    @AppStorage("notify_room_kitchen") var notifyKitchen: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "f9f9fe")
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        VStack(spacing: 16) {
                            SettingsHeader(title: "Hardware", trailingText: "CONNECTION")
                            
                            VStack(spacing: 0) {
                                Toggle("Simulator Mode (iOS Mock)", isOn: $isMockMode)
                                    .padding()
                                    .tint(Color.black)
                                
                                if !isMockMode {
                                    Divider()
                                    TextField("Physical Sensor IP", text: $hardwareDeviceURL)
                                        .padding()
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(24)
                            .padding(.horizontal)
                        }

                        VStack(spacing: 16) {
                            SettingsHeader(title: "Thresholds", trailingText: "SENSOR LIMITS")
                            
                            VStack(spacing: 24) {
                                ThresholdSlider(title: "PM2.5", icon: "wind", value: $pm25Threshold, range: 0...500, unit: "µg/m³", minLabel: "SAFE", maxLabel: "HAZARDOUS")
                                Divider()
                                ThresholdSlider(title: "CO2", icon: "carbon.dioxide.cloud", value: $co2Threshold, range: 400...5000, unit: "PPM", minLabel: "FRESH", maxLabel: "STALE")
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(24)
                            .padding(.horizontal)
                        }
                        
                        VStack(spacing: 16) {
                            SettingsHeader(title: "Notifications", trailingText: "ROOM ALERTS")
                            
                            VStack(spacing: 0) {
                                RoomToggleRow(title: "Living Room", icon: "sofa.fill", isOn: $notifyLiving)
                                Divider()
                                RoomToggleRow(title: "Bedroom", icon: "bed.double.fill", isOn: $notifyBedroom)
                                Divider()
                                RoomToggleRow(title: "Kitchen", icon: "refrigerator.fill", isOn: $notifyKitchen)
                            }
                            .background(Color.white)
                            .cornerRadius(24)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Global Settings")
            .navigationBarHidden(true)
        }
    }
}

struct SettingsHeader: View {
    let title: String
    let trailingText: String
    
    var body: some View {
        HStack(alignment: .bottom) {
            Text(title)
                .font(.system(size: 28, weight: .regular, design: .rounded))
            Spacer()
            Text(trailingText)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.gray)
                .padding(.bottom, 6)
        }
        .padding(.horizontal, 24)
    }
}

struct ThresholdSlider: View {
    let title: String
    let icon: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String
    let minLabel: String
    let maxLabel: String
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "1a1c1f"))
                Text(title)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "1a1c1f"))
                
                Spacer()
                
                Text("\(Int(value)) ")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "1a1c1f")) +
                Text(unit)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            Slider(value: $value, in: range)
                .tint(Color.black)
            
            HStack {
                Text(minLabel)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
                    .letterSpacing(1.2)
                Spacer()
                Text(maxLabel)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
                    .letterSpacing(1.2)
            }
        }
    }
}

struct RoomToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color(hex: "f0f5f1"))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(Color(hex: "0d631b"))
                )
            
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "1a1c1f"))
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.black)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

extension Text {
    func letterSpacing(_ tracking: CGFloat) -> some View {
        if #available(iOS 16.0, *) {
            return self.tracking(tracking)
        } else {
            return self
        }
    }
}
