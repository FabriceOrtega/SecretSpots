//
//  MapViewController.swift
//  SecretSpots
//
//  Created by Fabrice Ortega on 10/04/2021.
//

import UIKit
import RxCocoa
import RxSwift
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    // Dispose bag
    let disposeBag = DisposeBag()

    // Map view outlet
    @IBOutlet weak var mapView: MKMapView!
    
    // Filter buttons outlets
    @IBOutlet weak var activityButtonOutlet: UIButton!
    @IBOutlet weak var buildingButtonOutlet: UIButton!
    @IBOutlet weak var panoramaButtonOutlet: UIButton!
    @IBOutlet weak var restaurantButtonOutlet: UIButton!
    
    
    // Define the loaction Manager
    var locationManager = CLLocationManager()
    
    // Parameters to pass to the spot detail view
    var category: Category = .Activity
    var spotTitle = ""
    var spotDescription = ""
    var picture: UIImage = UIImage(named: "NYCPic")!
    
    // Corner radius
    let cornerRadius: CGFloat = 8
    
    // Link to the view model
    var viewModel: MapViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create instance of view Model
        viewModel = MapViewModel()
        
        // Set the origin of the map view
        mapView.setRegion(viewModel.setInitialMap(), animated: true)
        mapView.showsUserLocation = true
        //Set its delegate
        mapView.delegate = self
        
        //Authorization
        setAuthorizations()
        
        // Display spots each time the array is modified
        Spots.spots.spotList.asObservable()
            .subscribe(onNext: {_ in
                self.displaySpots()
        })
            .disposed(by: disposeBag)
        
        // Bring automaticcaly to user if user location was slower than the app to be launched
        bringBackToUserPosition()
        
        // Round the corners of the filter buttons
        activityButtonOutlet.layer.cornerRadius = cornerRadius
        buildingButtonOutlet.layer.cornerRadius = cornerRadius
        panoramaButtonOutlet.layer.cornerRadius = cornerRadius
        restaurantButtonOutlet.layer.cornerRadius = cornerRadius
        
        // Call the get spots requests
        callGetSpotRequest()
    }
    
    // Button to show user's location
    @IBAction func showUserLocationButton(_ sender: Any) {
        if let coor = mapView.userLocation.location?.coordinate {
            mapView.setCenter(coor, animated: true)
            locationManager.startUpdatingLocation()
        }
    }
    
    // Navigate to the spot addition
    @IBAction func addSpotButton(_ sender: Any) {
        performSegue(withIdentifier: "toSpotCreator", sender: nil)
    }
    
    // Search Button
    @IBAction func searchButton(_ sender: Any) {
        // Make the searchView appear
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    //Filter methods
    @IBAction func activityFilterButton(_ sender: Any) {
        viewModel.activityShown.toggle()
        displaySpots()
        activityButtonOutlet.alpha = alphaForFilterButtons(categoryShown: viewModel.activityShown)
    }
    
    @IBAction func buildingFilterButton(_ sender: Any) {
        viewModel.buildingShown.toggle()
        displaySpots()
        buildingButtonOutlet.alpha = alphaForFilterButtons(categoryShown: viewModel.buildingShown)
    }
    
    @IBAction func panoramaFilterButton(_ sender: Any) {
        viewModel.panoramaShown.toggle()
        displaySpots()
        panoramaButtonOutlet.alpha = alphaForFilterButtons(categoryShown: viewModel.panoramaShown)
    }
    
    @IBAction func restaurantFilterButton(_ sender: Any) {
        viewModel.restaurantShown.toggle()
        displaySpots()
        restaurantButtonOutlet.alpha = alphaForFilterButtons(categoryShown: viewModel.restaurantShown)
    }
    
    
    // Method to return the alpha for the button
    private func alphaForFilterButtons(categoryShown: Bool) -> CGFloat {
        if categoryShown {
            // Show the button with alpha 1 if category is shown
            return 1
        } else {
            // Show the button with alpha 0.3 if category is hidden
            return 0.3
        }
    }
    
    // Method to call the request with completion handler
    private func callGetSpotRequest() {
        
        var webservice = SpotWebservice(session: URLSession(configuration: .default))
        
        // Call the request
        webservice.getSpotRequest() { result in
            // Switch for succes or failure
            switch result {
            case .failure(let error):
                print(error)
            case .success(let spots):
                // if success, attribute the data
                Spots.spots.requestedSpots = spots
            }
        }
    }
    
    // Search methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // ignoring user
        self.view.isUserInteractionEnabled = false
        
        // Activity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        // Hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //Create the search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            // Stop the activity indicator
            activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            
            // Handle the response
            if response == nil {
                print("Error")
            } else {
                // Get the data
                if let lat = response?.boundingRegion.center.latitude,
                   let long = response?.boundingRegion.center.longitude {
                    // center the map
                    let coordinate: CLLocation = CLLocation(latitude: lat, longitude: long)
                    let region = MKCoordinateRegion(center: coordinate.coordinate,
                                                    latitudinalMeters: self.viewModel.regionLatitudinalMeters,
                                                    longitudinalMeters: self.viewModel.regionLongitudinalMeters)
                    self.mapView.setRegion(region, animated: true)
                    
                }
            }
        }
    }
    
    
    // Method to bring automatically the map on the usser after 1 second
    private func bringBackToUserPosition(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let coor = self.mapView.userLocation.location?.coordinate {
                self.mapView.setCenter(coor, animated: false)
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    
    // Method to set authorizations
    private func setAuthorizations() {
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
        
        }
    }
    
    // Method for the pins
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annot = annotation as? Spot {
            let identifier = "spotAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView != nil {
                annotationView!.annotation = annot
            } else {
                annotationView = MKAnnotationView(annotation: annot, reuseIdentifier: identifier)
                annotationView?.isEnabled = true
            }
            // Apply an image
            switch annot.category{
            case .Activity:
                annotationView?.image = imageCategory(image: #imageLiteral(resourceName: "Pin1"))
            case .Building:
                annotationView?.image = imageCategory(image: #imageLiteral(resourceName: "Pin2"))
            case .Panorama:
                annotationView?.image = imageCategory(image: #imageLiteral(resourceName: "Pin3"))
            case .Restaurant:
                annotationView?.image = imageCategory(image: #imageLiteral(resourceName: "Pin4"))
            }
            return annotationView
        }
        return nil
    }
    
    // Select a pin method
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if ((view.annotation as? Spot) != nil) {
            // Zoom effect0
            view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            
            // prepare parameters to pass
            let spotAnnotation = view.annotation as! Spot
            category = spotAnnotation.category
            spotTitle = spotAnnotation.title ?? spotAnnotation.category.rawValue
            spotDescription = spotAnnotation.subtitle ?? ""
            picture = spotAnnotation.picture ?? UIImage(named: "NYCPic")!
            
            // Open the pop over
            performSegue(withIdentifier: "toSpotDetails", sender: nil)
        }
    }
    

    // Method when deselcting
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        // Come back to pin image initial scale
        view.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    
    // Method to attribute image according category
    private func imageCategory(image: UIImage) -> UIImage? {
        let pinImage = image
        let size = CGSize(width: 40, height: 40)
        UIGraphicsBeginImageContext(size)
        pinImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        return resizedImage
    }
    
    // Method to display the spots
    private func displaySpots() {
        // erase all spots
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)

        // add all spots
        for spot in Spots.spots.spotList.value {
            
            // Add the activity category
            if viewModel.activityShown {
                if spot.category == .Activity {
                    mapView.addAnnotation(spot)
                }
            }
            
            // Add the building category
            if viewModel.buildingShown {
                if spot.category == .Building {
                    mapView.addAnnotation(spot)
                }
            }
            
            // Add the panorama category
            if viewModel.panoramaShown {
                if spot.category == .Panorama {
                    mapView.addAnnotation(spot)
                }
            }
            
            // Add the restaurant category
            if viewModel.restaurantShown {
                if spot.category == .Restaurant {
                    mapView.addAnnotation(spot)
                }
            }
            
        }
    }
    
    // Navigation method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSpotCreator" {
            let spotCreationVC = segue.destination as! SpotCreationViewController
            // Pass postion data here
            spotCreationVC.lat.accept(mapView.centerCoordinate.latitude)
            spotCreationVC.long.accept(mapView.centerCoordinate.longitude)
        } else if segue.identifier == "toSpotDetails" {
            let spotDetailsVC = segue.destination as! SpotDetailsViewController
            // Pass postion data here
            spotDetailsVC.category = category.rawValue
            spotDetailsVC.spotTitle = spotTitle
            spotDetailsVC.spotDescription = spotDescription
            spotDetailsVC.picture = picture
        }
    }

}

