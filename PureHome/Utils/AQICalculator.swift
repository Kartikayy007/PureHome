import Foundation

struct AQICalculator {
    static func calculate(pm25: Double) -> Int {
        let value = pm25
        let cLow: Double
        let cHigh: Double
        let iLow: Double
        let iHigh: Double
        
        switch value {
        case 0.0...12.0:
            cLow = 0.0; cHigh = 12.0; iLow = 0; iHigh = 50
        case 12.1...35.4:
            cLow = 12.1; cHigh = 35.4; iLow = 51; iHigh = 100
        case 35.5...55.4:
            cLow = 35.5; cHigh = 55.4; iLow = 101; iHigh = 150
        case 55.5...150.4:
            cLow = 55.5; cHigh = 150.4; iLow = 151; iHigh = 200
        case 150.5...250.4:
            cLow = 150.5; cHigh = 250.4; iLow = 201; iHigh = 300
        case 250.5...350.4:
            cLow = 250.5; cHigh = 350.4; iLow = 301; iHigh = 400
        case 350.5...500.4:
            cLow = 350.5; cHigh = 500.4; iLow = 401; iHigh = 500
        default:
            return 500
        }
        
        let aqi = ((iHigh - iLow) / (cHigh - cLow)) * (value - cLow) + iLow
        return Int(round(aqi))
    }
    
    static func category(for aqi: Int) -> AQICategory {
        if aqi <= 50 { return .good }
        if aqi <= 100 { return .moderate }
        if aqi <= 150 { return .unhealthyForSensitive }
        if aqi <= 200 { return .unhealthy }
        if aqi <= 300 { return .veryUnhealthy }
        return .hazardous
    }
}
