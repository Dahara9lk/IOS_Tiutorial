//
//  LocationService.swift
//  IOS_Tutorial
//
//  Created by student8 on 2026-07-09.
//

import Combine
import CoreLocation
import Foundation

final class LocationService: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var lastError: Error?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var isUpdating = false

    private let locationManager = CLLocationManager()

    override init() {
        authorizationStatus = locationManager.authorizationStatus
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdating()
        case .denied, .restricted:
            authorizationStatus = locationManager.authorizationStatus
        @unknown default:
            authorizationStatus = locationManager.authorizationStatus
        }
    }

    func startUpdating() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            isUpdating = true
        case .denied, .restricted:
            authorizationStatus = locationManager.authorizationStatus
            isUpdating = false
        @unknown default:
            authorizationStatus = locationManager.authorizationStatus
        }
    }

    func stopUpdating() {
        locationManager.stopUpdatingLocation()
        isUpdating = false
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            isUpdating = true
        } else {
            isUpdating = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastError = error
        isUpdating = false
    }
}

