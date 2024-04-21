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
