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

    func test_DefaultState_LocationListView(){
        let sut = load_LocationListVC_sut()
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 0)
        XCTAssertEqual(sut.customLocationTextField.text, "")
    }
    func test_FetchingOfLocations_LocationListView(){
        locationVM.loadLocations()
        XCTAssertEqual(locationVM.numberOfLocationsToDisplay, 0)
        
    }
    
    func test_CheckForNumberOfItemsCount_Correct(){
        locationVM.addLocationList(locations: createMockLocationObjectsFor(array: ["alpha","beta","charles"]))
        XCTAssertEqual(locationVM.numberOfLocationsToDisplay, 3)
    }
    
    func test_CheckForNumberOfItemsCount_EmptyLocation(){
        locationVM.addLocationList(locations: createMockLocationObjectsFor(array: ["alpha",nil,"charles"]))
        XCTAssertEqual(locationVM.numberOfLocationsToDisplay, 2)
    }

    func test_LocationNameForIndexOutOfRang_LocationListView(){
        let indexPath = IndexPath(row: 20, section: 1)
        let name = locationVM.getLocationNameFor(indexPath: indexPath)
        XCTAssertEqual(name, "")
    }
    
    func test_LocationNameForArrayItem_LocationListView(){
        let indexPath = IndexPath(row: 2, section: 1)
        locationVM.addLocationList(locations: createMockLocationObjectsFor(array: ["alpha","beta","charles"]))
        let name = locationVM.getLocationNameFor(indexPath: indexPath)
        XCTAssertEqual(name, "charles")
    }
    
    func test_LocationNameForArrayItemWithNilValue_LocationListView(){
        let indexPath = IndexPath(row: 1, section: 1)
        locationVM.addLocationList(locations: createMockLocationObjectsFor(array: ["alpha",nil,"charles"]))
        let name = locationVM.getLocationNameFor(indexPath: indexPath)
        XCTAssertEqual(name, "charles")
    }
    
    func test_LocationArrayFreshData_Success(){
        let expectation = XCTestExpectation(description: "LocationArray should be refreshed after reload is called")
        let indexPath = IndexPath(row: 1, section: 1)
        
        locationVM.addLocationList(locations: createMockLocationObjectsFor(array: ["alpha",nil,"charles"]))
        let name = locationVM.getLocationNameFor(indexPath: indexPath)
        XCTAssertEqual(name, "charles")
        locationVM.addLocationList(locations: createMockLocationObjectsFor(array: ["alpha","beta","charles"]))
        let name2 = locationVM.getLocationNameFor(indexPath: indexPath)
        XCTAssertEqual(name2, "beta")
        
        expectation.fulfill()

        
    }
    
    private func load_LocationListVC_sut() -> LocationListViewController{
        let viewModel = LocationListViewViewModel(networkService: WebService(urlSession: .shared))
        let sut = LocationListViewController(viewModel: viewModel)
        
        return sut
    }

    
    private func createMockLocationObjectsFor(array:[String?]) -> Locations{
        
        var locations = [Location]()
        _ = array.map { value in
            let temp = Location(name: value, lat: 1.0, long: 1.0)
            locations.append(temp)
        }
        let locationsArray:Locations = Locations(locations: locations)
        return locationsArray
    }
}
