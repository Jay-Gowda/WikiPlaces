//
//  LocationListViewModel.swift
//  WikiPlaces
//
//  Created by Jayanth Gowda on 20/04/24.
//

import Foundation
import UIKit
import Combine


/// Enum for async events from viewMode to ViewController
enum LocationListUIPublishType {
    case refreshList
    case enterValidString
    case showError(String)
}

/// Protocol for interaction between Location list view's ViewController and ViewModel
protocol LocationListViewProtocol {
    var listOfLocations:[Location]{get}
    var numberOfLocationsToDisplay:Int{get}
    func getLocationNameFor(indexPath:IndexPath) -> String
    func didSelectItem(indexPath:IndexPath)
    func userSelectedCustomLocation(latitude:String, longitude:String)
    func loadLocations()
    
    var uiPublisher:PassthroughSubject<LocationListUIPublishType, Never> {get}
}


class LocationListViewViewModel:LocationListViewProtocol {
    init(networkService: WebServiceProtocol = WebService(urlSession: .shared)) {
        self.networkService = networkService
    }
    var listOfLocations:[Location] = []
    var uiPublisher = PassthroughSubject<LocationListUIPublishType, Never>()
    private let networkService: WebServiceProtocol
    var numberOfLocationsToDisplay:Int{
        return listOfLocations.count
    }
    
    
    func reloadData() {
        uiPublisher.send(.refreshList)
    }
    
    func getLocationNameFor(indexPath:IndexPath) -> String{
        guard indexPath.row < numberOfLocationsToDisplay else {
            return ""
        }
        return listOfLocations[indexPath.row].name ?? ""
    }
    
    func getLocationCoordinatesFor(indexPath:IndexPath) -> (latitude:Double?, longitude:Double?){
        guard indexPath.row < numberOfLocationsToDisplay else {
            return (nil,nil)
        }
        let location = listOfLocations[indexPath.row]
        return (location.lat, location.long)
        
    }
    func didSelectItem(indexPath:IndexPath){
        let coOrdinates = getLocationCoordinatesFor(indexPath: indexPath)
        guard let latitude = coOrdinates.latitude, let longitude = coOrdinates.longitude else { return }
        openWikiAppFor(latitude: latitude, longitude: longitude)
        
    }
    func userSelectedCustomLocation(latitude:String, 
                                    longitude:String){
        if let latitude = Double(latitude), let longitude = Double(longitude){
            openWikiAppFor(latitude: latitude, longitude: longitude)
        }
    }
    
    
    func loadLocations() {
        networkService.request(urlData: .getLocations, 
                               type: Locations.self) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                switch result {
                case .success(let locations):
                    self.addLocationItemsToList(locations: locations)
                    self.reloadData()
                case .failure(let dataLoadError):
                    uiPublisher.send(.showError(dataLoadError.value))
                }
            }
        }
    }
    
    func addLocationItemsToList(locations:Locations){
        let filteredLocations = locations.locations?.filter { location in
            return location.name != nil
        }
        self.listOfLocations = filteredLocations ?? []
    }
    
    
    private func openWikiAppFor( latitude:Double, 
                                 longitude:Double) {
        let wikiDeepLinkUrl = "wikipedia://customLocation?"
        
        let locationCoOrds = "&lat=\(latitude)&long=\(longitude)"
        let urlString = wikiDeepLinkUrl + locationCoOrds
        let locationUrl = URL(string: urlString)
        
        guard let locationUrl else {
            self.uiPublisher.send(.showError("Enter URL is not valid \n \(urlString). Try again"))
            return
        }
        UIApplication.shared.open(locationUrl) { [weak self] status in
            guard let self = self else { return  }
            if !status{
                self.uiPublisher.send(.showError("Error launching WikiPedia, try again in some time"))
            }
        }
    }
}
