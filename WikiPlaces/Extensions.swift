//
//  Extensions.swift
//  WikiPlaces
//
//  Created by Jayanth Gowda on 24/04/24.
//

import Foundation
import UIKit

extension String{
    func isValidDecimalNumber() -> Bool {
        guard !self.isEmpty else{
            return false
        }
        let decimalRegex = "^[\\-]?(?:\\d+\\.\\d+|\\d+)$"
        let decimalPredicate = NSPredicate(format: "SELF MATCHES %@", decimalRegex)
        return decimalPredicate.evaluate(with: self)
    }
}


extension UIViewController{
    /// Alert: Display the alert dialogue window based on two types
    /// Alert with action
    /// Toast message which disappears in 2 seconds
    /// - Parameters:
    ///   - message: Message for the alert window
    ///   - title: Optional(Title for the alert content)
    ///   - actionRequired: Optional(Ok button for user to tap and terminate once he reads the message)
    func showAlert(message: String,
                   title: String = "",
                   actionRequired:Bool? = false) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alertController.dismiss(animated: true)
        }
        if actionRequired == true {
            alertController.addAction(okAction)
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                alertController.dismiss(animated: true)
            }
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
