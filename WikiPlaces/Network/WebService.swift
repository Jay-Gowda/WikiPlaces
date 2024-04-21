//
//  APIRequest.swift
//  WikiPlaces
//
//  Created by Jayanth Gowda on 20/04/24.
//

import Foundation

protocol WebServiceProtocol {
    func request<T: Decodable>(urlData: APIRoute,
                               type: T.Type,
                               completion: @escaping (Result<T, ApiError>) -> Void)
}

/// An enum to encode all the operations associated with specific endpoint
enum APIRoute {
    case getLocations
    
    // Base URL on which all the URL requests are based
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
    
    /// A method to convert given APIRoute case into URLRequest object
    /// - Returns: An instance of URLRequest
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

/// An enum to encode all the data load error conditions
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

 class WebService: WebServiceProtocol {
    
     let urlSession: URLSession = .shared
    let decoder: JSONDecoder = JSONDecoder()
    
    
    func request<T: Decodable>(urlData: APIRoute,
                               type: T.Type,
                               completion: @escaping (Result<T, ApiError>) -> Void) {

        
        urlSession.dataTask(with: urlData.asRequest()) { [weak self] (data, response, error) in
            
            guard let self else { return }
            
                guard (error as? URLError)?.code != .cancelled else {
                    completion(.failure(.backendError))
                    return
                }

            
            guard let data = data, !data.isEmpty else {
                completion(.failure(.noData))
                return
            }
            
            // Consider only responses with 200 response code as valid responses from API
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode != 200 {
                completion(.failure(.systemError(String(statusCode))))
                return
            }
            
            do {
                let response = try self.decoder.decode(type.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.dataInconsistency))
            }
        }.resume()

    }
}
