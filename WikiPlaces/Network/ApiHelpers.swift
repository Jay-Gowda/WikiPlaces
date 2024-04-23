//
//  ApiHelpers.swift
//  WikiPlaces
//
//  Created by Jayanth Gowda on 21/04/24.
//

import Foundation

enum APIRoute {
    case getLocations
    
    private var baseURLString: String { "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/" }
    
    private var url: URL? {
        switch self {
        case .getLocations:
            return URL(string: baseURLString + "main/locations.json")
        }
    }
    
    private var parameters: [URLQueryItem] {
        return []
    }
    
    
    func asRequest() -> URLRequest {
        guard let url = url else {
            preconditionFailure("Missing URL for route: \(self)")
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if !parameters.isEmpty {
            components?.queryItems = parameters
        }
        
        guard let parametrizedURL = components?.url else {
            preconditionFailure("Missing URL with parameters for url: \(url)")
        }
        
        return URLRequest(url: parametrizedURL)
    }
}

/// Enum for API error's
enum ApiError: Error {
    case backendError
    case badURL
    case systemError(String)
    case noData
    case dataInconsistency
    
    
    var value:String{
        switch self {
            
        case .backendError, .dataInconsistency:
            return "Try again after some time"
        case .badURL:
            return "API does not exist"
        case .systemError(let code):
            return "Failed with error \(code)"
        case .noData:
            return "No data, please try again"
            
        }
    }
}
