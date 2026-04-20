//
//  WeatherHistoryItem.swift
//  Project Noah
//
//  Created by EFABRO on 4/21/26.
//

import Foundation

struct WeatherHistoryItem: Codable, Equatable {
    let searchString: String
    let cityName: String
    let temperature: Int
    let description: String
    let timeOfSearch: String
    let iconName: String
    
    static func == (lhs: WeatherHistoryItem, rhs: WeatherHistoryItem) -> Bool {
        return lhs.searchString.lowercased() == rhs.searchString.lowercased()
    }
}
