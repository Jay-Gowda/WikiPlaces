//
//  NetworkLayerTests.swift
//  WikiPlacesTests
//
//  Created by Jayanth Gowda on 21/04/24.
//

import XCTest
@testable import WikiPlaces


final class NetworkLayerTests: XCTestCase {
    
    var urlSession: URLSession!
    var httpClient: WebServiceProtocol!
    
    override func setUp() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: config)
        
        httpClient = WebService(urlSession: urlSession)
    }
    
    func test_getLocationList_Success() throws {
        let urlData = URL(string: "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json")!
        let response = HTTPURLResponse(url: urlData,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: ["Content-Type": "application/json"])!
        let mockData: Data = Data(MockResponse.valid.utf8)
        
        MockURLProtocol.requestHandler = { request in
            return (response, mockData)
        }
        
        let expectation = XCTestExpectation(description: "response")
        httpClient.request(urlData: .getLocations, 
                           type: Locations.self) { result in
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
    
    func test_getLocationList_404() throws {
        let urlData = URL(string: "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json")!
        let response = HTTPURLResponse(url: urlData,
                                       statusCode: 400,
                                       httpVersion: nil,
                                       headerFields: ["Content-Type": "application/json"])!
        let mockData: Data = Data(MockResponse.valid.utf8)
        
        MockURLProtocol.requestHandler = { request in
            return (response, mockData)
        }
        
        let expectation = XCTestExpectation(description: "Failed response")
        httpClient.request(urlData: .getLocations,
                           type: Locations.self) { result in
            switch result {
            case .success(let locationsRes):
                XCTAssertThrowsError("Fatal Error")

            case .failure(let failure):
                XCTAssertEqual(failure.value
                               , "Failed with error 400")

                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2)
    }
}
