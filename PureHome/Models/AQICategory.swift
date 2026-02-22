import Foundation

enum AQICategory: String {
    case good = "Good"
    case moderate = "Moderate"
    case unhealthyForSensitive = "Unhealthy for Sensitive Groups"
    case unhealthy = "Unhealthy"
    case veryUnhealthy = "Very Unhealthy"
    case hazardous = "Hazardous"
    case unknown = "Unknown"
    
    var advice: String {
        switch self {
        case .good: return "Air quality is satisfactory, and air pollution poses little or no risk."
        case .moderate: return "Air quality is acceptable. However, there may be a risk for some people, particularly those who are unusually sensitive to air pollution."
        case .unhealthyForSensitive: return "Members of sensitive groups may experience health effects. The general public is less likely to be affected."
        case .unhealthy: return "Some members of the general public may experience health effects; members of sensitive groups may experience more serious health effects. Consider running purifier on max."
        case .veryUnhealthy: return "Health alert: The risk of health effects is increased for everyone."
        case .hazardous: return "Health warning of emergency conditions: everyone is more likely to be affected."
        case .unknown: return "Waiting for data."
        }
    }
}
