//
//  HistoryViewController.swift
//  Project Noah
//
//  Created by EFABRO on 4/19/26.
//
import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var searches: [WeatherHistoryItem] = []
    let viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recent Searches"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.searches = viewModel.fetchHistory()
        tableView.reloadData()
        
        print("DEBUG: History Loaded: \(searches)")
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        
        let historyItem = searches[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        
        content.text = historyItem.searchString
        
        content.secondaryText = "\(historyItem.cityName) • \(historyItem.temperature)°C"
        content.secondaryTextProperties.color = .secondaryLabel
        
        cell.contentConfiguration = content
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = searches[indexPath.row]
        performSegue(withIdentifier: "showDetail", sender: selectedItem)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let detailVC = segue.destination as? WeatherDetailViewController,
               let itemToSend = sender as? WeatherHistoryItem {
                detailVC.weatherItem = itemToSend
            }
        }
    }
}
