//
//  WeatherDetailViewController.swift
//  Project Noah
//
//  Created by EFABRO on 4/21/26.
//

import UIKit

class WeatherDetailViewController: UIViewController {

    // 1. Outlets for your Storyboard labels
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    // 2. This is the "bucket" that will hold the data sent from History
    var weatherItem: WeatherHistoryItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate the labels if we have data
        if let item = weatherItem {
            searchLabel.text = item.searchString
            cityLabel.text = item.cityName
            tempLabel.text = "\(item.temperature)°C"
            descriptionLabel.text = item.description
            timeLabel.text = "Searched at: \(item.timeOfSearch)"
        }
    }
}
