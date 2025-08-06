//
//  WidgetWeatherService.swift
//  WeatherismWidget
//
//  Created by Ammar Sufyan on 06/08/25.
//

import Foundation
import CoreLocation

// MARK: - Widget Weather Service
class WidgetWeatherService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let weatherBaseURL = "https://api.open-meteo.com/v1/forecast"
    private let geocodingBaseURL = "https://geocoding-api.open-meteo.com/v1/search"
    
    private var currentLocation: CLLocation?
    private var locationCompletion: ((CLLocation?) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func fetchCurrentLocationWeather() async -> WidgetWeatherData? {
        // First try to get fresh data if location is available
        if let location = await getCurrentLocation() {
            UserDefaults.shared.saveUserLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            if let weatherData = await fetchWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) {
                let locationName = await getLocationName(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                
                let widgetWeatherData = WidgetWeatherData(
                    temperature: weatherData.temperature,
                    weatherCode: weatherData.weatherCode,
                    humidity: weatherData.humidity,
                    windSpeed: weatherData.windSpeed,
                    locationName: locationName ?? "Current Location"
                )
                
                UserDefaults.shared.saveWeatherData(widgetWeatherData)
                UserDefaults.shared.markDataAsUpdated()
                
                return widgetWeatherData
            }
        }
        
        // Fallback to cached location if available
        if let savedLocation = UserDefaults.shared.loadUserLocation() {
            if let weatherData = await fetchWeatherData(latitude: savedLocation.latitude, longitude: savedLocation.longitude) {
                let locationName = await getLocationName(latitude: savedLocation.latitude, longitude: savedLocation.longitude)
                
                let widgetWeatherData = WidgetWeatherData(
                    temperature: weatherData.temperature,
                    weatherCode: weatherData.weatherCode,
                    humidity: weatherData.humidity,
                    windSpeed: weatherData.windSpeed,
                    locationName: locationName ?? "Saved Location"
                )
                
                UserDefaults.shared.saveWeatherData(widgetWeatherData)
                UserDefaults.shared.markDataAsUpdated()
                
                return widgetWeatherData
            }
        }
        
        // Final fallback to cached weather data
        return UserDefaults.shared.loadWeatherData()
    }
    
    private func getCurrentLocation() async -> CLLocation? {
        return await withCheckedContinuation { continuation in
            locationCompletion = { location in
                continuation.resume(returning: location)
            }
            
            switch locationManager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.requestLocation()
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            default:
                continuation.resume(returning: nil)
            }
            
            // Timeout after 10 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                if self.locationCompletion != nil {
                    self.locationCompletion?(nil)
                    self.locationCompletion = nil
                }
            }
        }
    }
    
    private func fetchWeatherData(latitude: Double, longitude: Double) async -> (temperature: Double, weatherCode: Int, humidity: Int, windSpeed: Double)? {
        let urlString = "\(weatherBaseURL)?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code&timezone=auto"
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            if let current = json?["current"] as? [String: Any],
               let temperature = current["temperature_2m"] as? Double,
               let humidity = current["relative_humidity_2m"] as? Int,
               let windSpeed = current["wind_speed_10m"] as? Double,
               let weatherCode = current["weather_code"] as? Int {
                
                return (temperature: temperature, weatherCode: weatherCode, humidity: humidity, windSpeed: windSpeed)
            }
        } catch {
            print("Error parsing weather data: \(error)")
        }
        
        return nil
    }
    
    private func getLocationName(latitude: Double, longitude: Double) async -> String? {
        let urlString = "https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=\(latitude)&longitude=\(longitude)&localityLanguage=en"
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            if let city = json?["city"] as? String, !city.isEmpty {
                return city
            } else if let locality = json?["locality"] as? String, !locality.isEmpty {
                return locality
            } else if let countryName = json?["countryName"] as? String {
                return countryName
            }
        } catch {
            print("Error getting location name: \(error)")
        }
        
        return nil
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        currentLocation = location
        locationCompletion?(location)
        locationCompletion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
        locationCompletion?(nil)
        locationCompletion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            locationCompletion?(nil)
            locationCompletion = nil
        default:
            break
        }
    }
}
