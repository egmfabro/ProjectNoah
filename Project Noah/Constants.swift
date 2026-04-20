//
//  Constants.swift
//  Project Noah
//
//  Created by EFABRO on 4/19/26.
//

import Foundation

struct APIConstants {
    static let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    static var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "WeatherApiKey") as? String else {
            fatalError("WeatherApiKey not found in Info.plist. Check your xcconfig setup!")
        }
        return key
    }
}
