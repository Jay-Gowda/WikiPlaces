//
//  NetworkLayerTests.swift
//  WikiPlacesTests
//
//  Created by Jayanth Gowda on 21/04/24.
//

import XCTest
@testable import WikiPlaces





////asdasd




final class NetworkLayerTests: XCTestCase {
    
    var urlSession: URLSession!
    var httpClient: WebServiceProtocol!
    
    override func setUp() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: config)
        
        httpClient = WebService(urlSession: urlSession)
    }
    
    func test_GetCat_Success() throws {
        let dummy = URL(string: "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json")!
        let response = HTTPURLResponse(url: dummy,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: ["Content-Type": "application/json"])!
        
        let mockString =
             """
                {
            "locations":
            [
            {
            "name": "Bengaluru",
            "lat": 52.3547498,
            "long": 4.8339215
            },
            {
            "name": "Mumbai",
            "lat": 19.0823998,
            "long": 72.8111468
            },
            {
            "name": "Copenhagen",
            "lat": 55.6713442,
            "long": 12.523785
            },
            {
            "lat": 40.4380638,
            "long": -3.7495758
            }
            ]
            }
            """
        
        let mockData: Data = Data(mockString.utf8)
        
        MockURLProtocol.requestHandler = { request in
            return (response, mockData)
        }
        
        let expectation = XCTestExpectation(description: "response")
        httpClient.request(urlData: .getLocations, type: Locations.self) { result in
            switch result {
            case .success(let locationsRes):
                XCTAssertEqual(locationsRes.locations?.first?.name, "Bengaluru")
                
                expectation.fulfill()
            case .failure(let failure):
                XCTAssertThrowsError(failure)
                
            }
        }
        wait(for: [expectation], timeout: 2)
    }
}
