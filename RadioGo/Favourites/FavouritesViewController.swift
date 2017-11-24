import UIKit
import Nuke
import DFCache

import XCGLogger

class FavouritesViewController: UITableViewController {
    let log = XCGLogger.default

    var manager = Nuke.Manager.shared
    
    let favouriteDataHelper = FavouriteDataHelper.shared
    let stationDataHelper = StationDataHelper.shared

    var searchController: UISearchController!
    
    var completedItems = [ Favourite ]()
    var filteredItems  = [ Favourite ]()
    
    init() {
        super.init(style: .plain)
        self.title = Strings.Favourites
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.definesPresentationContext = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(FavouritesViewController.editTouched(_:)))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ipod"), style: .plain, target: self, action: #selector(FavouritesViewController.showPlayerTouched(_:)))
        
        
        manager = CachingDataLoader.manager
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
    
    // MARK: - Table view data source

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
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "FavouriteViewCell")
        
        let item = self.completedItems[indexPath.row]
        
        cell.textLabel?.text = item.description
        cell.detailTextLabel?.text = item.streamUrl
        
        if let url = URL(string: item.imageUrl) {
            let request = Request(url: url)
            manager.loadImage(with: request, into: cell.imageView!)
        }
        if  cell.imageView?.image == nil {
            cell.imageView?.image = UIImage(named: "music")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = self.completedItems.remove(at: sourceIndexPath.row)
        self.completedItems.insert(itemToMove, at: destinationIndexPath.row)
        self.favouriteDataHelper.reorder(self.completedItems)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = self.find(row: indexPath.row)
            self.log.info("PlaylistDataHelper.delete: \(self.favouriteDataHelper.delete(id: item.id))")
            self.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.find(row: indexPath.row)
        
        if let station = self.stationDataHelper.find(id: item.stationId) {
            self.present(UINavigationController(rootViewController: PlayerViewController.shared), animated: true, completion: {
                PlayerViewController.shared.play(station: station)
            })
        } else {
            self.log.warning("stationId '\(item.stationId)' not found")
        }
    }
}

extension FavouritesViewController {
    
    @IBAction func editTouched(_ sender: UIBarButtonItem) {
        self.searchController.isActive = false
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(FavouritesViewController.doneTouched(_:)))
        
        self.tableView.setEditing(true, animated: true)
    }
    
    @IBAction func doneTouched(_ sender: UIBarButtonItem) {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(FavouritesViewController.editTouched(_:)))
        self.tableView.setEditing(false, animated: true)
    }
    
    @IBAction func showPlayerTouched(_ sender: UIBarButtonItem) {
        self.present(UINavigationController(rootViewController: PlayerViewController.shared), animated: true, completion: nil)
    }
    
    
    func reloadData() {
        self.completedItems = self.favouriteDataHelper.findAll()
        self.filteredItems.removeAll()
        if self.searchController != nil && 	self.searchController.isActive && self.searchController.searchBar.text != "" {
            let searchText = searchController.searchBar.text?.lowercased()
            self.filteredItems = self.completedItems.filter {
                return ( $0.description.lowercased().contains(searchText!) )
            }
        }
        self.tableView.reloadData()
    }
    
    func find(row: Int) -> Favourite {
        var item: Favourite!
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            item = self.filteredItems[row]
        } else {
            item = self.completedItems[row]
        }
        return item
    }
}

extension FavouritesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.reloadData()
    }
}
extension FavouritesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.reloadData()
    }
}
extension FavouritesViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
}
