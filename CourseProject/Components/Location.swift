//
//  Location.swift
//  CourseProject
//
//  Created by Daniel Bandola on 4/16/25.
//

import CoreLocation
import MapKit

@Observable
class Location: NSObject, CLLocationManagerDelegate {
    private let location = CLLocationManager()
    var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.424564, longitude: -111.928001),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    override init() {
        super.init()
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        location.requestWhenInUseAuthorization()
        location.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        region.center = lastLocation.coordinate
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                location.startUpdatingLocation()
            default:
                break
        }
    }
}
