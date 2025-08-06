//
//  SharedUserDefaults.swift
//  WeatherismWidget
//
//  Created by Ammar Sufyan on 06/08/25.
//

import Foundation

extension UserDefaults {
    static let shared = UserDefaults(suiteName: "group.weatherism.shared")!
    
    // Keys for shared data
    private enum Keys {
        static let lastWeatherData = "lastWeatherData"
        static let lastLocationName = "lastLocationName"
        static let lastUpdateTime = "lastUpdateTime"
        static let userLocationLatitude = "userLocationLatitude"
        static let userLocationLongitude = "userLocationLongitude"
    }
    
    // Save weather data to shared UserDefaults
    func saveWeatherData(_ weatherData: WidgetWeatherData) {
        if let data = try? JSONEncoder().encode(weatherData) {
            set(data, forKey: Keys.lastWeatherData)
        }
    }
    
    // Load weather data from shared UserDefaults
    func loadWeatherData() -> WidgetWeatherData? {
        guard let data = data(forKey: Keys.lastWeatherData),
              let weatherData = try? JSONDecoder().decode(WidgetWeatherData.self, from: data) else {
            return nil
        }
        return weatherData
    }
    
    // Save user location
    func saveUserLocation(latitude: Double, longitude: Double) {
        set(latitude, forKey: Keys.userLocationLatitude)
        set(longitude, forKey: Keys.userLocationLongitude)
    }
    
    // Load user location
    func loadUserLocation() -> (latitude: Double, longitude: Double)? {
        let latitude = double(forKey: Keys.userLocationLatitude)
        let longitude = double(forKey: Keys.userLocationLongitude)
        
        if latitude != 0 && longitude != 0 {
            return (latitude: latitude, longitude: longitude)
        }
        return nil
    }
    
    // Check if data is fresh (less than 30 minutes old)
    func isDataFresh() -> Bool {
        let lastUpdate = object(forKey: Keys.lastUpdateTime) as? Date ?? Date.distantPast
        return Date().timeIntervalSince(lastUpdate) < 30 * 60 // 30 minutes
    }
    
    // Mark data as updated
    func markDataAsUpdated() {
        set(Date(), forKey: Keys.lastUpdateTime)
    }
}
