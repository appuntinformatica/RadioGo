import UIKit
import SwiftyJSON
import Nuke
import DFCache
import FlagKit
import XCGLogger

class StationsViewController: UITableViewController {
    let log = XCGLogger.default

    var manager = Nuke.Manager.shared
    
    var searchController: UISearchController!
    
    let completedItems: [ Station ]!
    var filteredItems:  [ Station ]!
    
    init(title: String, items: Array<Station>) {
        self.completedItems = items
        super.init(style: .plain)
        self.title = title
        self.filteredItems = [ Station ]()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ipod"), style: .plain, target: self, action: #selector(StationsViewController.showPlayerAction(_:)))
        
        self.searchController = UISearchController(searchResultsController: nil)        
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.definesPresentationContext = true
        
        manager = CachingDataLoader.manager
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return StationCell.Height
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            return self.filteredItems.count
        } else {
            return self.completedItems.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = StationCell(style: .default, reuseIdentifier: StationCell.Identifier)
        
        let station = findStation(row: indexPath.row)
        
        cell.stationNameLabel.text = station.name
        cell.streamUrlLabel.text = station.streamUrl
        cell.countryImageView.image = UIImage(named: station.country, in: FlagKit.assetBundle, compatibleWith: nil)
        if let url = URL(string: station.imageUrl) {
            let request = Request(url: url)
            manager.loadImage(with: request, into: cell.stationImageView)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let station = findStation(row: indexPath.row)
        
        self.present(UINavigationController(rootViewController: PlayerViewController.shared), animated: true, completion: {
            PlayerViewController.shared.play(station: station)
        })
    }
    
    private func findStation(row: Int) -> Station {
        var station: Station!
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            station = self.filteredItems[row]
        } else {
            station = self.completedItems[row]
        }
        return station
    }
    
    @IBAction func showPlayerAction(_ sender: UIBarButtonItem) {
        self.present(UINavigationController(rootViewController: PlayerViewController.shared), animated: true, completion: nil)
    }    
    
    func reloadData() {
        self.filteredItems.removeAll()
        if self.searchController != nil && 	self.searchController.isActive && self.searchController.searchBar.text != "" {
            let searchText = searchController.searchBar.text?.lowercased()
            self.filteredItems = self.completedItems.filter {
                return $0.name.lowercased().contains(searchText!)
            }
        }
        self.tableView.reloadData()
        self.log.info("reloaded")
    }
}

extension StationsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.reloadData()
    }
}
extension StationsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.reloadData()
    }
}
extension StationsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
}
