//
//  WeatherismWidget.swift
//  WeatherismWidget
//
//  Created by Ammar Sufyan on 06/08/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    private let weatherService = WidgetWeatherService()
    
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            weatherData: WidgetWeatherData(
                temperature: 25.0,
                weatherCode: 0,
                humidity: 60,
                windSpeed: 10.0,
                locationName: "Current Location"
            )
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> WeatherEntry {
        let weatherData = await weatherService.fetchCurrentLocationWeather()
        return WeatherEntry(
            date: Date(),
            configuration: configuration,
            weatherData: weatherData ?? WidgetWeatherData(
                temperature: 25.0,
                weatherCode: 0,
                humidity: 60,
                windSpeed: 10.0,
                locationName: "Current Location"
            )
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<WeatherEntry> {
        var entries: [WeatherEntry] = []
        let currentDate = Date()
        
        // Fetch current weather data
        let weatherData = await weatherService.fetchCurrentLocationWeather()
        let defaultWeatherData = WidgetWeatherData(
            temperature: 25.0,
            weatherCode: 0,
            humidity: 60,
            windSpeed: 10.0,
            locationName: "Loading..."
        )
        
        let finalWeatherData = weatherData ?? defaultWeatherData
        
        // Create timeline entries
        for minuteOffset in stride(from: 0, to: 120, by: 30) { // Update every 30 minutes for 2 hours
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = WeatherEntry(
                date: entryDate,
                configuration: configuration,
                weatherData: finalWeatherData
            )
            entries.append(entry)
        }

        // Refresh timeline every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
        return Timeline(entries: entries, policy: .after(nextUpdate))
    }
}

struct WeatherEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let weatherData: WidgetWeatherData
}

struct WeatherismWidgetEntryView: View {
    var entry: Provider.Entry
    
    private var weatherCondition: WidgetWeatherCondition {
        WidgetWeatherCondition(from: entry.weatherData.weatherCode)
    }
    
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWeatherView(entry: entry, weatherCondition: weatherCondition)
        case .systemMedium:
            MediumWeatherView(entry: entry, weatherCondition: weatherCondition)
        case .systemLarge:
            LargeWeatherView(entry: entry, weatherCondition: weatherCondition)
        default:
            SmallWeatherView(entry: entry, weatherCondition: weatherCondition)
        }
    }
}

// MARK: - Small Widget View
struct SmallWeatherView: View {
    let entry: Provider.Entry
    let weatherCondition: WidgetWeatherCondition
    
    var body: some View {
        ZStack {
            weatherCondition.backgroundGradient
            
            VStack(spacing: 4) {
                // Location
                Text(entry.weatherData.locationName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Weather icon
                Image(systemName: weatherCondition.icon)
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(.white)
                
                // Temperature
                Text("\(Int(entry.weatherData.temperature.rounded()))°")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                // Condition
                Text(weatherCondition.displayName)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
            }
            .padding()
        }
    }
}

// MARK: - Medium Widget View
struct MediumWeatherView: View {
    let entry: Provider.Entry
    let weatherCondition: WidgetWeatherCondition
    
    var body: some View {
        ZStack {
            weatherCondition.backgroundGradient
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.weatherData.locationName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: weatherCondition.icon)
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(Int(entry.weatherData.temperature.rounded()))°")
                                .font(.system(size: 36, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(weatherCondition.displayName)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    WeatherDetailItem(
                        icon: "drop",
                        value: "\(entry.weatherData.humidity)%",
                        label: "Humidity"
                    )
                    
                    WeatherDetailItem(
                        icon: "wind",
                        value: "\(Int(entry.weatherData.windSpeed)) km/h",
                        label: "Wind"
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Large Widget View
struct LargeWeatherView: View {
    let entry: Provider.Entry
    let weatherCondition: WidgetWeatherCondition
    
    var body: some View {
        ZStack {
            weatherCondition.backgroundGradient
            
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 4) {
                    Text(entry.weatherData.locationName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text("Updated: \(entry.date, style: .time)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Main weather info
                HStack(alignment: .top, spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: weatherCondition.icon)
                            .font(.system(size: 60, weight: .light))
                            .foregroundColor(.white)
                        
                        Text(weatherCondition.displayName)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(Int(entry.weatherData.temperature.rounded()))°")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Celsius")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                // Weather details
                HStack(spacing: 20) {
                    WeatherDetailItem(
                        icon: "drop",
                        value: "\(entry.weatherData.humidity)%",
                        label: "Humidity"
                    )
                    
                    WeatherDetailItem(
                        icon: "wind",
                        value: "\(Int(entry.weatherData.windSpeed)) km/h",
                        label: "Wind Speed"
                    )
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Weather Detail Item
struct WeatherDetailItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct WeatherismWidget: Widget {
    let kind: String = "WeatherismWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            WeatherismWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Weatherism")
        .description("Stay updated with current weather conditions at your location.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
