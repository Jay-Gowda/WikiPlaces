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
    let urlSession: URLSession
    let decoder: JSONDecoder = JSONDecoder()
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
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
