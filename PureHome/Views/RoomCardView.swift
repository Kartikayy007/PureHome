import SwiftUI
import Charts

struct RoomCardView: View {
    @ObservedObject var viewModel: RoomViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text(viewModel.device.name)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "1a1c1f"))
                Spacer()
                statusIndicator
            }
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.currentAQI)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "1a1c1f"))
                    Text("AQI")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "40493d"))
                    
                    if !viewModel.recentReadings.isEmpty {
                        Chart(viewModel.recentReadings) { reading in
                            LineMark(
                                x: .value("Time", reading.timestamp),
                                y: .value("AQI", reading.pm2_5)
                            )
                            .foregroundStyle(Color(hex: "0d631b"))
                            .lineStyle(StrokeStyle(lineWidth: 2))
                            .interpolationMethod(.monotone)
                        }
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                        .frame(width: 80, height: 36)
                        .padding(.top, 4)
                    }
                }
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(viewModel.dominantPollutant) elevated")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "1a1c1f"))
                    
                    if let reading = viewModel.device.lastReading {
                        Text(reading.timestamp, style: .time)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "40493d"))
                    } else {
                        Text("Waiting for data...")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "40493d"))
                    }
                }
            }
        }
        .padding(32)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 40, x: 0, y: 20)
        .opacity(viewModel.device.status == .offline ? 0.6 : 1.0)
    }
    
    @ViewBuilder
    private var statusIndicator: some View {
        let isOnline = viewModel.device.status == .online
        
        HStack(spacing: 8) {
            Circle()
                .fill(isOnline ? Color.white : Color(hex: "40493d"))
                .frame(width: 6, height: 6)
            
            Text(isOnline ? "Online" : "Offline")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isOnline ? .white : Color(hex: "40493d"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isOnline ? Color(hex: "0d631b") : Color(hex: "e2e2e7"))
        .cornerRadius(9999)
    }
}
