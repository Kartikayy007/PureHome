import SwiftUI

struct AQIGaugeView: View {
    let aqi: Int
    let category: AQICategory
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.1, to: 0.9)
                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(.degrees(90))
            
            Circle()
                .trim(from: 0.1, to: min(0.1 + (CGFloat(aqi) / 500.0) * 0.8, 0.9))
                .stroke(ColorMapper.color(for: category), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(.degrees(90))
                .animation(.easeOut(duration: 1.0), value: aqi)
            
            VStack {
                Text("\(aqi)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(ColorMapper.color(for: category))
                Text(category.rawValue)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
    }
}
