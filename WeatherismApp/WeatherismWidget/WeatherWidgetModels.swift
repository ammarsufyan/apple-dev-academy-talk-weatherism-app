//
//  WeatherWidgetModels.swift
//  WeatherismWidget
//
//  Created by Ammar Sufyan on 06/08/25.
//

import Foundation
import SwiftUI

// MARK: - Widget Weather Models
struct WidgetWeatherData: Codable {
    let temperature: Double
    let weatherCode: Int
    let humidity: Int
    let windSpeed: Double
    let locationName: String
    let lastUpdated: Date
    
    init(temperature: Double, weatherCode: Int, humidity: Int, windSpeed: Double, locationName: String, lastUpdated: Date = Date()) {
        self.temperature = temperature
        self.weatherCode = weatherCode
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.locationName = locationName
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Weather Condition for Widget
enum WidgetWeatherCondition: CaseIterable {
    case clear
    case partlyCloudy
    case cloudy
    case foggy
    case drizzle
    case rainy
    case snowy
    case stormy
    
    init(from weatherCode: Int) {
        switch weatherCode {
        case 0, 1:
            self = .clear
        case 2:
            self = .partlyCloudy
        case 3:
            self = .cloudy
        case 45, 48:
            self = .foggy
        case 51, 53, 55:
            self = .drizzle
        case 61, 63, 65, 80, 81, 82:
            self = .rainy
        case 71, 73, 75, 77, 85, 86:
            self = .snowy
        case 95, 96, 99:
            self = .stormy
        default:
            self = .clear
        }
    }
    
    var displayName: String {
        switch self {
        case .clear: return "Clear"
        case .partlyCloudy: return "Partly Cloudy"
        case .cloudy: return "Cloudy"
        case .foggy: return "Foggy"
        case .drizzle: return "Drizzle"
        case .rainy: return "Rainy"
        case .snowy: return "Snowy"
        case .stormy: return "Stormy"
        }
    }
    
    var icon: String {
        switch self {
        case .clear: return "sun.max"
        case .partlyCloudy: return "cloud.sun"
        case .cloudy: return "cloud"
        case .foggy: return "cloud.fog"
        case .drizzle: return "cloud.drizzle"
        case .rainy: return "cloud.rain"
        case .snowy: return "cloud.snow"
        case .stormy: return "cloud.bolt.rain"
        }
    }
    
    var backgroundGradient: LinearGradient {
        switch self {
        case .clear:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.orange.opacity(0.8),
                    Color.yellow.opacity(0.6),
                    Color.blue.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .partlyCloudy:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.7),
                    Color.orange.opacity(0.5),
                    Color.purple.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cloudy:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.8),
                    Color.blue.opacity(0.5),
                    Color.gray.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .foggy:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.9),
                    Color.white.opacity(0.7),
                    Color.gray.opacity(0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .drizzle:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.7),
                    Color.blue.opacity(0.5),
                    Color.purple.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .rainy:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.9),
                    Color.blue.opacity(0.7),
                    Color.indigo.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .snowy:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.9),
                    Color.blue.opacity(0.4),
                    Color.cyan.opacity(0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .stormy:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.8),
                    Color.purple.opacity(0.7),
                    Color.indigo.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
