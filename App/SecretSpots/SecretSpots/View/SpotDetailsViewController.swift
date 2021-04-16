//
//  SpotDetailsViewController.swift
//  SecretSpots
//
//  Created by Fabrice Ortega on 12/04/2021.
//

import UIKit

class SpotDetailsViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var spotDetailsView: UIView!
    @IBOutlet weak var pictureOutlet: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var backgroundImageOutlet: UIImageView!
    
    // Corner radius
    let cornerRadius: CGFloat = 25
    let smallCornerRadius: CGFloat = 8
    
    // ParameterS
    var category = ""
    var spotTitle = ""
    var spotDescription = ""
    var picture: UIImage = UIImage(named: "NYCPic")!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Graphics parameters
        spotDetailsView.layer.cornerRadius = cornerRadius
        pictureOutlet.layer.cornerRadius = cornerRadius
        
        // Update background according to the category
        changeBackgroundandSetTexts()
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Change background according category
    func changeBackgroundandSetTexts(){
        
        // Switch for the background
        switch category {
        case "Activity":
            backgroundImageOutlet.image = #imageLiteral(resourceName: "Activity")
            spotDetailsView.backgroundColor = UIColor(named: "ActivityColor")
        case "Building":
            backgroundImageOutlet.image = #imageLiteral(resourceName: "Building")
            spotDetailsView.backgroundColor = UIColor(named: "BuildingColor")
        case "Panorama":
            backgroundImageOutlet.image = #imageLiteral(resourceName: "Panorama")
            spotDetailsView.backgroundColor = UIColor(named: "PanoramaColor")
        case "Restaurant":
            backgroundImageOutlet.image = #imageLiteral(resourceName: "Restaurant")
            spotDetailsView.backgroundColor = UIColor(named: "RestaurantColor")
            titleLabel.textColor = .white
            descriptionLabel.textColor = .white
        default:
            backgroundImageOutlet.image = #imageLiteral(resourceName: "Activity")
            spotDetailsView.backgroundColor = UIColor(named: "ActivityColor")
        }
        
        // Set the labels and pictures
        titleLabel.text = spotTitle
        descriptionLabel.text = spotDescription
        pictureOutlet.image = picture
    }
}
