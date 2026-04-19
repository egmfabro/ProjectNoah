//
//  WeatherService.swift
//  Project Noah
//
//  Created by EFABRO on 4/19/26.
//

import Foundation

class WeatherService {
    static let shared = WeatherService()
    private init() {}
    
    func fetchWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let urlString = "\(APIConstants.baseURL)?lat=\(lat)&lon=\(lon)&appid=\(APIConstants.apiKey)&units=metric"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let weatherData = try decoder.decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(weatherData))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
