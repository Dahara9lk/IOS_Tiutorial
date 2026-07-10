//
//  LocationService.swift
//  IOS_Tutorial
//
//  Created by student8 on 2026-07-09.
//

import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastError: Error?
    @Published var isUpdating = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10 // Update every 10 meters
        manager.allowsBackgroundLocationUpdates = false
        manager.pausesLocationUpdatesAutomatically = true
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        guard !isUpdating else { return }
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
            isUpdating = true
            print("📍 Started updating location")
        }
    }
    
    func stopUpdating() {
        manager.stopUpdatingLocation()
        isUpdating = false
        print("📍 Stopped updating location")
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .notDetermined:
            print("📍 Location: Not determined")
        case .restricted:
            print("📍 Location: Restricted")
        case .denied:
            print("📍 Location: Denied - Please enable in Settings")
        case .authorizedWhenInUse, .authorizedAlways:
            print("📍 Location: Authorized")
            startUpdating()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location
        }
        
        print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        print("📍 Accuracy: \(location.horizontalAccuracy)m")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.lastError = error
        }
        print("❌ Location error: \(error.localizedDescription)")
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                print("📍 Location services denied")
            case .network:
                print("📍 Network error fetching location")
            default:
                break
            }
        }
    }
}
