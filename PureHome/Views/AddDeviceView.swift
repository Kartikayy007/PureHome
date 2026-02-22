import SwiftUI
import CoreBluetooth

struct AddDeviceView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var connectionMethod = 0 // 0 = Wi-Fi, 1 = Bluetooth
    @State private var wifiURL: String = ""
    @StateObject private var scannerVM = BLEScannerViewModel()
    
    var body: some View {
        ZStack {
            Color(hex: "f9f9fe").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                
                Picker("Connection Method", selection: $connectionMethod) {
                    Text("Connect via Wi-Fi").tag(0)
                    Text("Connect via Bluetooth").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if connectionMethod == 0 {
                    wifiSetupView
                } else {
                    bluetoothSetupView
                }
                
                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle("Add Device")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var wifiSetupView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WebSocket Configuration")
                .font(.system(size: 18, weight: .bold, design: .rounded))
            
            TextField("Enter WebSocket URL (ws://...)", text: $wifiURL)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
            
            Button(action: {
            }) {
                Text("Connect Device")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "0d631b"))
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal)
    }
    
    private var bluetoothSetupView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Nearby Devices")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                
                if scannerVM.isScanning {
                    ProgressView()
                } else {
                    Button("Scan") {
                        scannerVM.startScan()
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "0d631b"))
                }
            }
            .padding(.horizontal)
            
            if scannerVM.discoveredPeripherals.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                        .padding(.top, 40)
                    Text("No devices found.")
                        .foregroundColor(.gray)
                }
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(scannerVM.discoveredPeripherals, id: \.identifier) { peripheral in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(scannerVM.peripheralNames[peripheral.identifier] ?? "Unknown Device")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    Text(peripheral.identifier.uuidString)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Button("Connect") {
                                    let name = scannerVM.peripheralNames[peripheral.identifier] ?? "BLE Device"
                                    homeViewModel.addBLERoom(peripheral: peripheral, displayName: name)
                                    dismiss()
                                }
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(hex: "0d631b").opacity(0.1))
                                .foregroundColor(Color(hex: "0d631b"))
                                .cornerRadius(8)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .onAppear {
            scannerVM.startScan()
        }
        .onDisappear {
            scannerVM.stopScan()
        }
    }
}
