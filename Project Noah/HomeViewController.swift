//
//  HomeViewController.swift
//  Project Noah
//
//  Created by EFABRO on 4/19/26.
//
import UIKit
import MapKit
import CoreLocation

class HomeViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var isDayOrNight: UIImageView!
    
    @IBOutlet weak var locationView: UIVisualEffectView!
    @IBOutlet weak var tempView: UIVisualEffectView!
    @IBOutlet weak var sunriseView: UIVisualEffectView!
    @IBOutlet weak var sunsetView: UIVisualEffectView!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    
    private let locationManager = CLLocationManager()
    private let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let overlays: [UIView] = [searchBar, tabBar, isDayOrNight, locationView, tempView, sunriseView, sunsetView]
        overlays.forEach { view.bringSubviewToFront($0) }
        mapView.frame = view.bounds
        mapView.overrideUserInterfaceStyle = .dark
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        searchBar.delegate = self
        searchBar.searchTextField.textColor = .white
        tabBar.delegate = self
        
        setupGlassUI()
        setupViewModelObservers()
    }
    
    private func setupGlassUI() {
        let glassViews = [locationView, tempView, sunriseView, sunsetView]
        glassViews.forEach { glass in
            glass?.alpha = 0.7
            glass?.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
            glass?.layer.cornerRadius = 20
            glass?.clipsToBounds = false
            glass?.layer.masksToBounds = false
            glass?.layer.shadowColor = UIColor.black.cgColor
            glass?.layer.shadowOpacity = 0.2
            glass?.layer.shadowOffset = CGSize(width: 0, height: 8)
            glass?.layer.shadowRadius = 15
            
            if let contentView = glass?.subviews.first(where: { !($0 is UILabel) }) {
                contentView.layer.cornerRadius = 20
                contentView.layer.masksToBounds = true
            }
            
            glass?.layer.borderWidth = 1.0
            glass?.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        }
    }
    
    private func setupViewModelObservers() {
        viewModel.onWeatherUpdate = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self, let data = self.viewModel.weatherData else { return }
                
                let iconName: String
                let iconColor: UIColor
                
                if let weatherCondition = data.weather.first {
                    let weatherID = weatherCondition.id
                    let isRaining = (200...599).contains(weatherID)
                    
                    if isRaining {
                        iconName = "cloud.rain.fill"
                        iconColor = .systemBlue
                    } else if self.viewModel.isNight {
                        iconName = "moon.stars.fill"
                        iconColor = .systemPurple
                    } else {
                        iconName = "sun.max.fill"
                        iconColor = .systemYellow
                    }
                } else {
                    iconName = self.viewModel.isNight ? "moon.stars.fill" : "sun.max.fill"
                    iconColor = self.viewModel.isNight ? .systemPurple : .systemYellow
                }
                
                self.isDayOrNight.image = UIImage(systemName: iconName)
                self.isDayOrNight.tintColor = iconColor
                self.locationLabel.text = "\(data.name), \(data.sys.country)"
                self.tempLabel.text = "\(Int(data.main.temp))°C"
                self.sunriseLabel.text = "Sunrise: \(self.viewModel.formatTime(from: Int(data.sys.sunrise), offsetInSeconds: data.timezone))"
                self.sunsetLabel.text = "Sunset: \(self.viewModel.formatTime(from: Int(data.sys.sunset), offsetInSeconds: data.timezone))"
            }
        }
        
        viewModel.onLocationUpdate = { [weak self] location in
            let region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            self?.mapView.setRegion(region, animated: true)
        }
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        viewModel.handleLocationUpdate(locations)
        manager.stopUpdatingLocation()
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        
        viewModel.searchLocation(for: searchText)

        searchBar.resignFirstResponder()
    }
}

extension HomeViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item) else { return }
        
        if index == 0 {
            searchBar.text = ""
            locationManager.startUpdatingLocation()
            searchBar.resignFirstResponder()
        } else if index == 1 {
            print("History tab pressed: Navigating...")
            performSegue(withIdentifier: "goToHistory", sender: self)
        }
    }
}
