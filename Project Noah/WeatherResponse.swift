//
//  WeatherResponse.swift
//  Project Noah
//
//  Created by EFABRO on 4/19/26.
//

import Foundation

struct WeatherResponse: Codable {
    let name: String
    let dt: TimeInterval
    let main: Main
    let weather: [Weather]
    let sys: Sys
    let timezone: Int
}

struct Main: Codable {
    let temp: Double
    let humidity: Int
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}


struct Sys: Codable {
    let country: String
    let sunrise: TimeInterval
    let sunset: TimeInterval
}
