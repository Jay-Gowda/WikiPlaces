//
//  NetworkLayerTests.swift
//  WikiPlacesTests
//
//  Created by Jayanth Gowda on 21/04/24.
//

import XCTest
@testable import WikiPlaces

//final class NetworkLayerTests: XCTestCase {
//    var mockSession: URLSession!
//    let validResponse = HTTPURLResponse(url: URL(string: "https://something.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
//    let invalidResponse = HTTPURLResponse(url: URL(string: "https://something.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)
//    var networkService: WebService!
//    
//    override func setUp() {
//        super.setUp()
//        setupURLProtocolMock()
//        networkService = RequestHandler(urlSession: mockSession)
//    }
//    
//    override func tearDown() {
//        super.tearDown()
//        URLProtocolMock.mockURLs = [:]
//    }
//    
//    func testThatNetworkServiceCorrectlyHandlesValidResponse() {
//        
//        let urlWithValidData = "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json"
//        let validData = JSONDataReader.getDataFromJSONFile(with: "locations")
//        
//        URLProtocolMock.mockURLs = [
//            URL(string: urlWithValidData): (nil, validData, validResponse)
//        ]
//        
//        let expectation = XCTestExpectation(description: "Successful JSON to model conversion while loading valid data from API")
//        
//        networkService.request(type: Locations.self, route: .getLocations) { result in
//            if case .success = result {
//                // No-op. If we reached here, that means we passed the test
//            } else {
//                XCTFail("Test failed. Expected to get the valid data without any error. Failed due to unexpected result")
//            }
//            expectation.fulfill()
//        }
//        
//        wait(for: [expectation], timeout: 1.0)
//    }
//
//}
