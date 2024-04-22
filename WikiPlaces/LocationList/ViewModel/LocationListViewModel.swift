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
    func userSelectedCustomLocation(locationText:String?)
    func loadLocations()
    
    var uiPublisher:PassthroughSubject<LocationListUIPublishType, Never> {get}
}


class LocationListViewViewModel:LocationListViewProtocol {
    init(networkService: WebServiceProtocol = WebService()) {
        self.networkService = networkService
    }
    var listOfLocations:[Location] = []
    var uiPublisher = PassthroughSubject<LocationListUIPublishType, Never>()
    
    var numberOfLocationsToDisplay:Int{
        return listOfLocations.count
    }
    
    private let networkService: WebServiceProtocol
    
    func reloadData() {
        uiPublisher.send(.refreshList)
    }
    
    func getLocationNameFor(indexPath:IndexPath) -> String{
        guard indexPath.row < numberOfLocationsToDisplay else {
            return ""
        }
        return listOfLocations[indexPath.row].name ?? ""
    }
    func didSelectItem(indexPath:IndexPath){
        let locationName = getLocationNameFor(indexPath: indexPath)
        if !locationName.isEmpty{
            openWikiAppFor(location: locationName)
        }
    }
    func userSelectedCustomLocation(locationText:String?){
        let trimmedString = locationText?.trimmingCharacters(in: .whitespaces)
        if let locationString = trimmedString, !locationString.isEmpty{
            openWikiAppFor(location: locationString)
        }else{
            uiPublisher.send(.enterValidString)
        }
    }
    
    func loadLocations() {
        networkService.request(urlData: .getLocations, type: Locations.self) { [weak self] result in
            
            guard let self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                switch result {
                case .success(let locations):
                    self.addLocationList(locations: locations)
                    self.reloadData()
                case .failure(let dataLoadError):
                    uiPublisher.send(.showError(dataLoadError.value))
                }
            }
        }
    }
    
    func addLocationList(locations:Locations){
        let filteredLocations = locations.locations?.filter { location in
            return location.name != nil
        }
        self.listOfLocations = filteredLocations ?? []
    }
    
    
    private func openWikiAppFor(location: String) {
        let wikiDeepLinkUrl = "wikipedia://places?WMFArticleURL=https://en.wikipedia.org/"
        if let encodedLocation = location.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
            let urlString = wikiDeepLinkUrl + encodedLocation
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
        } else {
            self.uiPublisher.send(.showError("Error launching WikiPedia, try again in some time"))
        }
    }
}
