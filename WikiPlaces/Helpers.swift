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

