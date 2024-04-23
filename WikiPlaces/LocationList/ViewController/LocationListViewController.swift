//
//  LocationListViewController.swift
//  WikiPlaces
//
//  Created by Jayanth Gowda on 20/04/24.
//

import UIKit
import Combine

class LocationListViewController: UIViewController {
    let viewModel: LocationListViewProtocol
    var vmSubscription:AnyCancellable?
    
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var customLocationTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    
    ///  Init of Location listing screen
    /// - Parameter viewModel: LocationListViewModel which requires Network layer dependency for API calls
    init(viewModel: LocationListViewProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initiateUiElements()
        viewModel.loadLocations()
        
    }
    
    func initiateUiElements(){
        LocationItemTableViewCell.registerNib(tableView: self.tableView)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refreshTableView(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        bindViewModel()
        latitudeTextField.placeholder = NSLocalizedString("Latitude", comment: "LatitudeTextField")
        longitudeTextField.placeholder = NSLocalizedString("Longitude", comment: "LongitudeTextField")
    }
    
    /// Subscription for combine to fetch events from ViewMode
    func bindViewModel(){
        vmSubscription = viewModel.uiPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] task in
                guard let self = self else{return}
                switch task {
                case .refreshList:
                    self.tableView.reloadData()
                    refreshControl.endRefreshing()
                case .enterValidString:
                    self.showAlert(message: "Please enter a search location")
                case .showError(let message):
                    self.showAlert(message: message)
                }
            })
    }
    @IBAction func openLocationButtonAction(_ sender: Any) {
        guard let latitude = latitudeTextField.text, let longitude = longitudeTextField.text else{
            return
        }
        if latitude.isValidDecimalNumber() && longitude.isValidDecimalNumber(){
            viewModel.userSelectedCustomLocation(latitude: latitude, longitude: longitude)
        }
    }
    
    
    @objc func refreshTableView(_ sender: AnyObject) {
        viewModel.loadLocations()
    }
}

extension LocationListViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfLocationsToDisplay
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = LocationItemTableViewCell.dequeue(tableView: tableView, indexPath: indexPath)
        cell.titleLabel.text = viewModel.getLocationNameFor(indexPath: indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(indexPath: indexPath)
    }
}


