//
//  HomeViewModel.swift
//  Project Noah
//
//  Created by EFABRO on 4/19/26.
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
    
    // Updated fetchWeather to take an optional search string
    func fetchWeather(for location: CLLocation, searchString: String? = nil) {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        WeatherService.shared.fetchWeather(lat: lat, lon: lon) { [weak self] result in
            switch result {
            case .success(let response):
                self?.weatherData = response
                self?.onWeatherUpdate?()
                
                // Only save to history if this was triggered by a search string
                if let query = searchString {
                    self?.saveSearchToHistory(query: query, response: response)
                }
                
            case .failure(let error):
                print("DEBUG: API Error: \(error.localizedDescription)")
            }
        }
    }
    
    func searchLocation(for query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let item = response?.mapItems.first else { return }
            
            let coordinate = item.location.coordinate
            let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            self?.onLocationUpdate?(newLocation)
            
            // Pass the original query ("Ortigas") to fetchWeather
            self?.fetchWeather(for: newLocation, searchString: query)
        }
    }

    // MARK: - History Persistence Logic

    func saveSearchToHistory(query: String, response: WeatherResponse) {
        var history = fetchHistory()
        
        // Create the "Package" using both the user's query and API data
        let newItem = WeatherHistoryItem(
            searchString: query,
            cityName: response.name,
            temperature: Int(response.main.temp),
            description: response.weather.first?.description.capitalized ?? "",
            timeOfSearch: formatTime(from: Int(response.dt), offsetInSeconds: response.timezone),
            iconName: response.weather.first?.main ?? "cloud.fill"
        )
        
        // Equatable handles the check: it compares searchString (e.g., "ortigas" == "Ortigas")
        if let index = history.firstIndex(of: newItem) {
            history.remove(at: index)
        }
        
        history.insert(newItem, at: 0)
        
        if history.count > 15 { history.removeLast() }
        
        saveToPlist(history)
    }

    func fetchHistory() -> [WeatherHistoryItem] {
        let archiveURL = getHistoryURL()
        guard let data = try? Data(contentsOf: archiveURL) else { return [] }
        return (try? PropertyListDecoder().decode([WeatherHistoryItem].self, from: data)) ?? []
    }
    
    private func saveToPlist(_ history: [WeatherHistoryItem]) {
        let archiveURL = getHistoryURL()
        let encoder = PropertyListEncoder()
        try? encoder.encode(history).write(to: archiveURL)
        print("DEBUG: History updated with \(history.count) items.")
    }

    private func getHistoryURL() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("searchHistory").appendingPathExtension("plist")
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
}
