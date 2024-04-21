//
//  LocationListViewModel.swift
//  WikiPlaces
//
//  Created by Jayanth Gowda on 20/04/24.
//

import Foundation
import UIKit
import Combine

enum LocationListUIPublishType {
    case refreshList
    case enterValidString
    case showError(String)
    
}

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
    var listOfLocations:[Location] = []
    var uiPublisher = PassthroughSubject<LocationListUIPublishType, Never>()
    
    var numberOfLocationsToDisplay:Int{
        return listOfLocations.count
    }
    
    
    private let networkService: WebServiceProtocol
    let title: String
    
    
    init(networkService: WebServiceProtocol = WebService()) {
        self.networkService = networkService
        self.title = "Locations"
    }
    
    func reloadData() {
        uiPublisher.send(.refreshList)
    }
    
    func getLocationNameFor(indexPath:IndexPath) -> String{
        return listOfLocations[indexPath.row].name ?? ""
    }
    func didSelectItem(indexPath:IndexPath){
        let locationName = getLocationNameFor(indexPath: indexPath)
        openWikiAppFor(location: locationName)
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
                    let filteredLocations = locations.locations?.filter { location in
                        return location.name != nil && location.lat != nil && location.long != nil
                    }
                    
                    if let list = filteredLocations{
                        self.listOfLocations = list
                        self.reloadData()
                    }
                    
                case .failure(let dataLoadError):
                    uiPublisher.send(.showError(dataLoadError.value))
                }
            }
        }
    }
    
    
    func openWikiAppFor(location: String) {
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
                    self.uiPublisher.send(.showError("Error launching WikiPeda, try again in some time"))
                }
            }
            
        } else {
            self.uiPublisher.send(.showError("Error launching WikiPeda, try again in some time"))
        }
    }
}
