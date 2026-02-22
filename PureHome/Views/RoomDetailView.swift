import SwiftUI
import Charts

struct RoomDetailView: View {
    @ObservedObject var viewModel: RoomViewModel
    @State private var showWhyExplanation = false
    @State private var selectedMetric: ChartMetric = .pm25
    
    enum ChartMetric: String, CaseIterable {
        case pm25 = "PM2.5"
        case co2 = "CO2"
        case temperature = "Temperature"
        case humidity = "Humidity"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { showWhyExplanation.toggle() }) {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                        }
                    }
                    AQIGaugeView(aqi: viewModel.currentAQI, category: viewModel.aqiCategory)
                        .frame(height: 250)
                    
                    Text(viewModel.aqiCategory.advice)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    MetricTile(title: "PM2.5", value: "\(viewModel.device.lastReading?.pm2_5 ?? 0) µg/m³", icon: "aqi.medium")
                    MetricTile(title: "PM10", value: "\(viewModel.device.lastReading?.pm10 ?? 0) µg/m³", icon: "wind")
                    MetricTile(title: "CO2", value: "\(viewModel.device.lastReading?.co2 ?? 0) ppm", icon: "carbon.dioxide.cloud")
                    MetricTile(title: "Temp", value: String(format: "%.1f°C", viewModel.device.lastReading?.temperature ?? 0), icon: "thermometer")
                    MetricTile(title: "Humidity", value: "\(viewModel.device.lastReading?.humidity ?? 0)%", icon: "humidity")
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Historical Trends")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "1a1c1f"))
                            
                        Spacer()
                        
                        Picker("Metric", selection: $selectedMetric) {
                            ForEach(ChartMetric.allCases, id: \.self) { metric in
                                Text(metric.rawValue).tag(metric)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 220)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    Chart {
                        ForEach(viewModel.recentReadings) { reading in
                            LineMark(
                                x: .value("Time", reading.timestamp),
                                y: .value("Value", chartValue(for: reading, metric: selectedMetric))
                            )
                            .foregroundStyle(Color(hex: "0d631b"))
                            .lineStyle(StrokeStyle(lineWidth: 2))
                            .interpolationMethod(.monotone)
                            
                            AreaMark(
                                x: .value("Time", reading.timestamp),
                                y: .value("Value", chartValue(for: reading, metric: selectedMetric))
                            )
                            .foregroundStyle(Color(hex: "0d631b").opacity(0.1))
                            .interpolationMethod(.monotone)
                        }
                        
                        if let limit = getThreshold(for: selectedMetric) {
                            RuleMark(
                                y: .value("Threshold", limit)
                            )
                            .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                            .foregroundStyle(Color.red)
                            .annotation(position: .top, alignment: .leading) {
                                Text("Alert Limit")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 4)) { value in
                            AxisValueLabel(format: .dateTime.hour().minute().second())
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisGridLine().foregroundStyle(Color.gray.opacity(0.1))
                            AxisValueLabel()
                        }
                    }
                    .frame(height: 220)
                    .padding()
                }
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.04), radius: 40, x: 0, y: 20)
                
                AirCompositionView(reading: viewModel.device.lastReading)
            }
            .padding()
        }
        .navigationTitle(viewModel.device.name)
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showWhyExplanation) {
            SwiftUI.Alert(
                title: Text("Why is the AQI \(viewModel.currentAQI)?"),
                message: Text("Your \(viewModel.device.name) AQI is \(viewModel.currentAQI) (\(viewModel.aqiCategory.rawValue)). The main contributor is \(viewModel.dominantPollutant). This is likely caused by indoor activities or poor ventilation. Consider running the purifier on high for 20 minutes."),
                dismissButton: .default(Text("Got It"))
            )
        }
    }
    
    private func chartValue(for reading: SensorReading, metric: ChartMetric) -> Double {
        switch metric {
        case .pm25: return Double(reading.pm2_5)
        case .co2: return Double(reading.co2)
        case .temperature: return reading.temperature
        case .humidity: return Double(reading.humidity)
        }
    }
    
    private func getThreshold(for metric: ChartMetric) -> Double? {
        if metric == .pm25 {
            let key = "pm25Threshold"
            if UserDefaults.standard.object(forKey: key) == nil { return 100.0 }
            return UserDefaults.standard.double(forKey: key)
        } else if metric == .co2 {
            let key = "co2Threshold"
            if UserDefaults.standard.object(forKey: key) == nil { return 1000.0 }
            return UserDefaults.standard.double(forKey: key)
        }
        return nil
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct AirCompositionView: View {
    let reading: SensorReading?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Air Quality Composition")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "1a1c1f"))
            
            if let r = reading {
                let total = max(1.0, Double(r.pm2_5 + r.pm10 + (r.co2 / 10)))
                let p25 = Double(r.pm2_5) / total
                let p10 = Double(r.pm10) / total
                let co2 = Double(r.co2 / 10) / total
                
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        Rectangle().fill(Color(hex: "0d631b")).frame(width: max(0, geo.size.width * p25))
                        Rectangle().fill(Color(hex: "569562")).frame(width: max(0, geo.size.width * p10))
                        Rectangle().fill(Color(.systemGray4)).frame(width: max(0, geo.size.width * co2))
                    }
                    .cornerRadius(8)
                }
                .frame(height: 16)
                
                HStack {
                    Circle().fill(Color(hex: "0d631b")).frame(width: 8, height: 8)
                    Text("PM2.5").font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Circle().fill(Color(hex: "569562")).frame(width: 8, height: 8)
                    Text("PM10").font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Circle().fill(Color(.systemGray4)).frame(width: 8, height: 8)
                    Text("CO2 (Scaled)").font(.caption).foregroundColor(.secondary)
                }
            } else {
                Text("Awaiting IoT Telemetry...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 40, x: 0, y: 20)
    }
}
