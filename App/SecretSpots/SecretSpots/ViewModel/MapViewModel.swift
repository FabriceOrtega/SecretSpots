//
//  MapViewModel.swift
//  SecretSpots
//
//  Created by Fabrice Ortega on 10/04/2021.
//

import Foundation
import RxCocoa
import RxSwift
import MapKit

class MapViewModel {
    
    // Visible region in meters
    let regionLatitudinalMeters : CLLocationDistance = 1000
    let regionLongitudinalMeters : CLLocationDistance = 1000
    
    // Booleans to filter by cateroy
    var activityShown = true
    var buildingShown = true
    var panoramaShown = true
    var restaurantShown = true
    

    // Method to define the zone with central point of the region
    func setInitialMap() -> MKCoordinateRegion {
        
        // Location manager
        let locationManager = CLLocationManager()
        
        // Set lat and long
        if let lat = locationManager.location?.coordinate.latitude,
           let long = locationManager.location?.coordinate.longitude {
            // Create base location
            let locationBase = CLLocation(latitude: lat, longitude: long)
            print(lat)
            print(long)
            
            return MKCoordinateRegion(center: locationBase.coordinate,
                               latitudinalMeters: regionLatitudinalMeters,
                               longitudinalMeters: regionLongitudinalMeters)
        } else {
            // Create deufault location : Apple campus
            let locationBase = CLLocation(latitude: 37.33182, longitude: -122.03118)
            
            return MKCoordinateRegion(center: locationBase.coordinate,
                               latitudinalMeters: regionLatitudinalMeters,
                               longitudinalMeters: regionLongitudinalMeters)
        }
    }
    
    
}



