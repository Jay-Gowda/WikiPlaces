//
//  LocationListViewModelTests.swift
//  WikiPlacesTests
//
//  Created by Jayanth Gowda on 21/04/24.
//

import XCTest
@testable import WikiPlaces

final class LocationListViewModelTests: XCTestCase {
    
    let locationVM = LocationListViewViewModel(networkService: WebService(urlSession: .shared))
    
    func test_FetchingOfLocations_LocationListView(){
        locationVM.loadLocations()
        XCTAssertEqual(locationVM.numberOfLocationsToDisplay, 0)
        
    }
    
    func test_numberOfLocationItems_validName(){
        locationVM.addLocationItemsToList(locations: createMockLocationObjectsFor(array: ["alpha","beta","charles"]))
        XCTAssertEqual(locationVM.numberOfLocationsToDisplay, 3)
    }
    func test_numberOfLocationItems_nameValueNil(){
        locationVM.addLocationItemsToList(locations: createMockLocationObjectsFor(array: ["alpha",nil,"charles"]))
        XCTAssertEqual(locationVM.numberOfLocationsToDisplay, 2)
    }
    
    
    func test_locationNameForLocationItems_indexOutOfRange(){
        let indexPath = IndexPath(row: 20, section: 1)
        let name = locationVM.getLocationNameFor(indexPath: indexPath)
        XCTAssertEqual(name, "")
    }
    func test_locationNameForLocationItems_validRange(){
        let indexPath = IndexPath(row: 2, section: 1)
        locationVM.addLocationItemsToList(locations: createMockLocationObjectsFor(array: ["alpha","beta","charles"]))
        let name = locationVM.getLocationNameFor(indexPath: indexPath)
        XCTAssertEqual(name, "charles")
    }
    func test_locationNameForLocationItems_WithNilValue(){
        let indexPath = IndexPath(row: 1, section: 1)
        locationVM.addLocationItemsToList(locations: createMockLocationObjectsFor(array: ["alpha",nil,"charles"]))
        let name = locationVM.getLocationNameFor(indexPath: indexPath)
        XCTAssertEqual(name, "charles")
    }
    
    
    func test_locationCoOrdinatesForLocation_indexOutOfRange(){
        let indexPath = IndexPath(row: 20, section: 1)
        let location = locationVM.getLocationCoordinatesFor(indexPath: indexPath)
        XCTAssertNil(location.latitude)
    }
    func test_locationCoOrdinatesForLocation_validRange(){
        let indexPath = IndexPath(row: 2, section: 1)
        let mockArray = createMockLocationObjectsFor(array: ["alpha","beta","charles"],lat: [1.0,2.0,3.0], long: [1.1,2.2,3.3])
        locationVM.addLocationItemsToList(locations: mockArray)
        let location = locationVM.getLocationCoordinatesFor(indexPath: indexPath)
        XCTAssertEqual(location.latitude, 3.0)
        XCTAssertEqual(location.longitude, 3.3)
    }
    func test_locationCoOrdinatesForLocation_nilValue(){
        let indexPath = IndexPath(row: 1, section: 1)
        let mockArray = createMockLocationObjectsFor(array: ["alpha","beta","charles"],lat: [1.0,nil,3.0], long: [1.1,nil,3.3])
        locationVM.addLocationItemsToList(locations: mockArray)
        let location = locationVM.getLocationCoordinatesFor(indexPath: indexPath)
        XCTAssertNil(location.latitude)
        XCTAssertNil(location.longitude)
    }
    
    
    func test_LocationArrayFreshData_Valid(){
        let expectation = XCTestExpectation(description: "LocationArray should be refreshed after reload is called")
        let indexPath = IndexPath(row: 1, section: 1)
        
        locationVM.addLocationItemsToList(locations: createMockLocationObjectsFor(array: ["alpha",nil,"charles"]))
        let name = locationVM.getLocationNameFor(indexPath: indexPath)
        XCTAssertEqual(name, "charles")
        locationVM.addLocationItemsToList(locations: createMockLocationObjectsFor(array: ["alpha","beta","charles"]))
        let name2 = locationVM.getLocationNameFor(indexPath: indexPath)
        XCTAssertEqual(name2, "beta")
        
        expectation.fulfill()
        
        
    }
    
    
    
    
    
}

//Private method helpers
extension LocationListViewModelTests{
    
    
    private func load_LocationListVC_sut() -> LocationListViewController{
        let viewModel = LocationListViewViewModel(networkService: WebService(urlSession: .shared))
        let sut = LocationListViewController(viewModel: viewModel)
        
        return sut
    }

    
    private func createMockLocationObjectsFor(array:[String?],
                                              lat:[Double?] = [1.0,2.0,3.0],
                                              long:[Double?] = [1.0,2.0,3.0]) -> Locations{
        var locations = [Location]()
        
        for (index, _) in array.enumerated() {
            let temp = Location(name: array[index], lat: lat[index], long: long[index])
            locations.append(temp)
        }

        let locationsArray:Locations = Locations(locations: locations)
        return locationsArray
    }
}
