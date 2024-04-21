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
    var vmSubscripton:AnyCancellable?
    
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
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        bindViewModel()
    }
    
    /// Subscription for combine to fetch events from ViewMode
    func bindViewModel(){
        vmSubscripton = viewModel.uiPublisher
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
        viewModel.userSelectedCustomLocation(locationText: customLocationTextField.text)
    }
    
    
    @objc func refresh(_ sender: AnyObject) {
        // Code to refresh table view
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

