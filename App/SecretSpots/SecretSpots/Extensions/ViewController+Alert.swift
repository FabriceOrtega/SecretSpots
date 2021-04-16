//
//  ViewController+Alert.swift
//  SecretSpots
//
//  Created by Fabrice Ortega on 13/04/202
//

import UIKit

// Extension for the alert method
extension UIViewController {
    // Method to call an alert
    func alert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return self.present(alertVC, animated: true, completion: nil)
    }
}
