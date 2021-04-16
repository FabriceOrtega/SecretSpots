//
//  Spots.swift
//  SecretSpots
//
//  Created by Fabrice Ortega on 13/04/2021.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit

class Spots {
    
    // Pattern singleton
    public static let spots = Spots()
    
    // Array for the request
    var requestedSpots = [RequestedSpot]() {
        didSet {
            DispatchQueue.main.async {
                self.convertedToSpotObject()
            }
        }
    }
    
    // Observed array of spots to display
    let spotList: BehaviorRelay<[Spot]> = BehaviorRelay(value: [])
    
    // Public init for pattern singleton
    public init() {}
    
    // Method to be able to create Spot objects
    private func convertedToSpotObject() {
        for requetedSpot in requestedSpots {
            let spot = Spot(title: requetedSpot.title ?? "Default",
                            subtitle: requetedSpot.subtitle ?? "",
                            coordinate: CLLocationCoordinate2D(latitude: requetedSpot.lat, longitude: requetedSpot.long),
                            category: Category(rawValue: requetedSpot.category) ?? .Activity,
                            picture: UIImage(named: "NYCPic")!)
            
            // Append in the new list
            spotList.accept(spotList.value + [spot])
        }
    }
    
}
