//
//  Locations.swift
//  WikiPlaces
//
//  Created by Jayanth Gowda on 21/04/24.
//

import Foundation


struct Locations: Codable {
    let locations: [Location]?
}

// MARK: - Location
struct Location: Codable {
    let name: String?
    let lat, long: Double?
}
