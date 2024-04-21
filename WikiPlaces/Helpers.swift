//
//  Helpers.swift
//  WikiPlaces
//
//  Created by Jayanth Gowda on 21/04/24.
//

import Foundation
import UIKit

protocol CellIdentifier {
    static func registerNib(tableView: UITableView)
    static func dequeue(tableView: UITableView, indexPath: IndexPath) -> Self
}

extension CellIdentifier {
    static func registerNib(tableView: UITableView) {
        let id = String(describing: self)
        tableView.register(UINib(nibName: id, bundle: nil), forCellReuseIdentifier: id)
    }
    
    static func dequeue(tableView: UITableView, indexPath: IndexPath) -> Self {
        let id = String(describing: self)
        return tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! Self
    }
}
extension UIViewController{
    func showAlert(message: String, title: String = "", actionRequired:Bool? = false) {
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
