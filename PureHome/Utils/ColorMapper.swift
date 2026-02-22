import SwiftUI

struct ColorMapper {
    static func color(for category: AQICategory) -> Color {
        switch category {
        case .good: return .green
        case .moderate: return .yellow
        case .unhealthyForSensitive: return .orange
        case .unhealthy: return .red
        case .veryUnhealthy: return .purple
        case .hazardous: return Color(red: 128/255, green: 0, blue: 0)
        case .unknown: return .gray
        }
    }
}
