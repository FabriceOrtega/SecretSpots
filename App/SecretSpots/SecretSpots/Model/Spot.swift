//
//  Spot.swift
//  SecretSpots
//
//  Created by Fabrice Ortega on 11/04/2021.
//

import MapKit

class Spot: NSObject, MKAnnotation {
    
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let category: Category
    let picture: UIImage?
    
    init (title: String, subtitle: String, coordinate: CLLocationCoordinate2D, category: Category, picture: UIImage) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.category = category
        self.picture = picture
    }
    
}

enum Category: String {
    case Activity, Building, Panorama, Restaurant
}
