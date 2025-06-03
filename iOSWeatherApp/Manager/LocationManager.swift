//
//  LocationManager.swift
//  iOSWeatherApp
//
//  Created by Edwin Mbaabu on 12/9/24.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    @Published var location: CLLocationCoordinate2D? {
        didSet {
            if let location = location {
                onLocationChange?(location)
            }
        }
    }
    @Published var locationName: String? // New property to store location name
    private var manager = CLLocationManager()
    private let geocoder = CLGeocoder() // Geocoder for reverse geocoding
    var onLocationChange: ((CLLocationCoordinate2D) -> Void)?
    
    func checkLocationAuthorization() {
        manager.delegate = self
        manager.startUpdatingLocation()
        
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location restricted due to parental control")
        case .denied:
            print("Location Denied")
        case .authorizedAlways, .authorizedWhenInUse:
            print("Location authorized")
            location = manager.location?.coordinate
            if let currentLocation = manager.location {
                fetchLocationName(from: currentLocation)
            }
        @unknown default:
            print("Location Service disabled")
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.first else { return }
        location = newLocation.coordinate
        fetchLocationName(from: newLocation)
    }
    
    private func fetchLocationName(from location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, error == nil, let placemark = placemarks?.first else {
                print("Error fetching location name: \(error?.localizedDescription ?? "Unknown error")")
                self?.locationName = "Unknown Location"
                return
            }
            self.locationName = placemark.locality ?? "Unknown Location"
        }
    }
}
