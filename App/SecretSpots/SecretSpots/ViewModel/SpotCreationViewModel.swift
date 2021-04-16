//
//  SpotCreationViewModel.swift
//  SecretSpots
//
//  Created by Fabrice Ortega on 11/04/2021.
//

import Foundation
import RxCocoa
import RxSwift
import MapKit

class SpotCreationViewModel {
    
    // Dispose bag
    private let disposeBag = DisposeBag()
    
    // Create binding parameters
    let title = BehaviorSubject(value: "")
    let description = BehaviorSubject(value: "")
    let lat = BehaviorSubject<CLLocationDegrees>(value: 0)
    let long = BehaviorSubject<CLLocationDegrees>(value: 0)
    let center = BehaviorSubject<CLLocationCoordinate2D >(value: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    let category = BehaviorSubject<String>(value: "")
    let picture = BehaviorSubject<UIImage>(value: UIImage(named: "NYCPic")!)
    
    // Create a parameter to fill the picker view
    let pickerViewArray: [String] = [Category.Activity.rawValue, Category.Building.rawValue, Category.Panorama.rawValue, Category.Restaurant.rawValue]
    
    init() {
        
    }
    
    // Method to create the spot
    func createSpot(){
        Observable.combineLatest(title, description, center, category, picture)
            .subscribe(onNext: { (spotTitle, spotDescription, mapCenter, spotCategory, spotPicture) in
            let spot = Spot(title: spotTitle,
                            subtitle: spotDescription,
                            coordinate: mapCenter,
                            category: Category(rawValue: spotCategory) ?? .Activity,
                            picture: spotPicture)
                // Add to the array
                Spots.spots.spotList.accept(Spots.spots.spotList.value + [spot])
                //Save in teh webservice here
                let webservice = SpotWebservice(session: URLSession(configuration: .default))
                webservice.postNewSpot(title: spotTitle, subtitle: spotDescription, coordinate: mapCenter, category: Category(rawValue: spotCategory) ?? .Activity)
        })
            .disposed(by: disposeBag)
    }
    
    // Method to define the zone with central point of the region
    func setInitialMap() -> MKCoordinateRegion {
        
        // Visible region in meters
        let regionLatitudinalMeters : CLLocationDistance = 500
        let regionLongitudinalMeters : CLLocationDistance = 500
        
        var locationBase = CLLocation(latitude: 0, longitude: 0)
        
        Observable.combineLatest(lat, long)
            .subscribe(onNext: { (latitude, longitude) in
                
                locationBase = CLLocation(latitude: latitude, longitude: longitude)
                
            })
            .disposed(by: disposeBag)
        
        return MKCoordinateRegion(center: locationBase.coordinate,
                           latitudinalMeters: regionLatitudinalMeters,
                           longitudinalMeters: regionLongitudinalMeters)
        
    }
    
}
