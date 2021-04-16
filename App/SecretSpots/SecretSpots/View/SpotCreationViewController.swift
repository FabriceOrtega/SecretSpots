//
//  SpotCreationViewController.swift
//  SecretSpots
//
//  Created by Fabrice Ortega on 11/04/2021.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

class SpotCreationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var createSpotButton: UIButton!
    @IBOutlet weak var spotMapView: MKMapView!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var pictureAddedLabel: UILabel!
    @IBOutlet weak var addPictureButton: UIButton!
    
    // Corner radius
    let cornerRadius: CGFloat = 8
    
    // Parameters for the initial alt and long
    let lat = BehaviorRelay<CLLocationDegrees>(value: 0)
    let long = BehaviorRelay<CLLocationDegrees>(value: 0)
    
    // Parameter for pickerView cataegory
    let category = BehaviorRelay<String>(value: "")
    
    // Parameter to capture the center of the map view
    let center = BehaviorRelay<CLLocationCoordinate2D >(value: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    // Parameter for pickerView cataegory
    let picture = BehaviorRelay<UIImage>(value: UIImage(named: "NYCPic")!)
    
    // Dispose bag
    private let disposeBag = DisposeBag()
    
    // Link to the view model
    var viewModel: SpotCreationViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create view model instance
        viewModel = SpotCreationViewModel()
        
        // Bindings
        setUpBindings()
        
        // Set map region
        spotMapView.setRegion(viewModel.setInitialMap(), animated: true)
        
        // Delegates
        categoryPickerView.delegate = self
        
        // Graphic parameters
        setUpGraphics()
        
    }
    
    // Binding creation method
    private func setUpBindings() {
        // Title
        titleTextField.rx.text.orEmpty
            .bind(to: viewModel.title)
            .disposed(by: disposeBag)
        
        // Description
        descriptionTextField.rx.text.orEmpty
            .bind(to: viewModel.description)
            .disposed(by: disposeBag)
        
        // Create spot button
//        createSpotButton.rx.tap
//            .bind{[weak self] in self?.viewModel.createSpot()}
//            .disposed(by: disposeBag)
        
        // Create lat and long bindings
        lat.bind(to: viewModel.lat).disposed(by: disposeBag)
        long.bind(to: viewModel.long).disposed(by: disposeBag)
        
        // Create binding for the center
        center.bind(to: viewModel.center).disposed(by: disposeBag)
        
        // Create binding for the category
        category.bind(to: viewModel.category).disposed(by: disposeBag)
        
        // Create binding for the picture
        picture.bind(to: viewModel.picture).disposed(by: disposeBag)
    }
    
    @IBAction func createSpotButton(_ sender: Any) {
        if titleTextField.text == "" {
            // Show alert
            alert(title: "Title empty", message: "Please enter a spot title")
        } else {
            // Create the spot
            viewModel.createSpot()
            dismiss(animated: true, completion: nil)
            center.accept(spotMapView.centerCoordinate)
        }
    }
    
    // Add picture button
    @IBAction func addPictureButton(_ sender: Any) {
        getSource()
    }
    
    
    // Picker view methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.pickerViewArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.pickerViewArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        category.accept(viewModel.pickerViewArray[row])
    }
    
    // Method for graphic elements
    func setUpGraphics(){
        titleTextField.layer.borderWidth = 1.0
        titleTextField.layer.cornerRadius = cornerRadius
        titleTextField.attributedPlaceholder = NSAttributedString(string: "Title",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        descriptionTextField.layer.borderWidth = 1.0
        descriptionTextField.layer.cornerRadius = cornerRadius
        descriptionTextField.attributedPlaceholder = NSAttributedString(string: "Description",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        createSpotButton.layer.cornerRadius = cornerRadius
        categoryPickerView.setValue(UIColor(named: "Text Color"), forKey: "textColor")
        spotMapView.layer.cornerRadius = cornerRadius
        addPictureButton.layer.cornerRadius = cornerRadius
    }
    
    // Methods to show an alert to the user to choose between camera and library
    func getSource() {
        let alert = UIAlertController(title: "Image Selection", message: "Please select the source of the picture", preferredStyle: .actionSheet)
        // Camera button
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .camera)
        }))
        // Photo library button
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        // Cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
        print("addPicture")
    }
    
    //Get image , method is called in getSource method with source type as parameter
    func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = sourceType
            image.allowsEditing = true
            //picturePicker = pictureGetImage
            self.present(image, animated: true, completion: nil)
            print("getImage")
        }
    }
    
    //Attribute the picture to the correct UIImage, is called when image is selected
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            //picturePicker.image = image
            picture.accept(image)
            // Show text that confirms the picture selection
            pictureAddedLabel.isHidden = false
            
        } else {
            alert(title: "Error", message: "Secrot Spots could not access the camera nor the photo library")
        }
        
        self.dismiss(animated: true, completion: nil)
        print("imagePickerController")
    }
    
}
