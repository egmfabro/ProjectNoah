//
//  HomeViewModel.swift
//  Project Noah
//
//  Created by EFABRO on 4/17/26.
//
import Foundation
import CoreLocation
import MapKit

class HomeViewModel {
    var onLocationUpdate: ((CLLocation) -> Void)?
    var onWeatherUpdate: (() -> Void)?
    var weatherData: WeatherResponse?
    
    var isNight: Bool {
        guard let dt = weatherData?.dt,
              let sunrise = weatherData?.sys.sunrise,
              let sunset = weatherData?.sys.sunset else { return false }
        return dt < sunrise || dt > sunset
    }
    
    func handleLocationUpdate(_ locations: [CLLocation]) {
        guard let location = locations.first else { return }
        onLocationUpdate?(location)
        
        fetchWeather(for: location)
    }
    
    func fetchWeather(for location: CLLocation) {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        print("DEBUG: Fetching weather for Lat: \(lat), Lon: \(lon)")
        
        WeatherService.shared.fetchWeather(lat: lat, lon: lon) { [weak self] result in
            switch result {
            case .success(let response):
                self?.weatherData = response
                self?.onWeatherUpdate?()
                let timeOfDay = (self?.isNight ?? false) ? "NIGHT" : "DAY"
                
                // TEST PRINT
                print("--- API SUCCESS ---")
                print("City: \(response.name) | Mode: \(timeOfDay)")
                print("-------------------")
                
            case .failure(let error):
                print("--- API FAILURE ---")
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func formatTime(from timestamp: Int?, offsetInSeconds: Int) -> String {
        guard let timestamp = timestamp else { return "--:--" }
        
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        if let cityTimeZone = TimeZone(secondsFromGMT: offsetInSeconds) {
            formatter.timeZone = cityTimeZone
        }
        
        return formatter.string(from: date)
    }
    
    func searchLocation(for query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let item = response?.mapItems.first else {
                print("DEBUG: No location found for \(query)")
                return
            }
            
            let coordinate = item.location.coordinate
            let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            self?.onLocationUpdate?(newLocation)
            self?.fetchWeather(for: newLocation)
        }
    }
}
