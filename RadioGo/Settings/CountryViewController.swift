import UIKit
import XCGLogger
import FlagKit
import SwiftyUserDefaults

class CountryViewController: UITableViewController {
    let log = XCGLogger.default
    
    let countryDataHelper = CountryDataHelper.shared
    
    var searchController: UISearchController!
    
    var completedItems = [ Country ]()
    var filteredItems  = [ Country ]()
    
    init() {
        super.init(style: .plain)
        self.title = Strings.Country
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(CountryViewController.cancelTouched(sender:)))
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.definesPresentationContext = true
        
        self.reloadData()
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
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CountryViewCell")
        
        let item = find(row: indexPath.row)
        
        cell.textLabel?.text = item.name
        cell.imageView?.image = UIImage(named: item.code, in: FlagKit.assetBundle, compatibleWith: nil)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = find(row: indexPath.row)
        self.log.info(item)
        
        DefaultsKeys.setCountryCode(item.code)

        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: SettingsViewController.SettingsNotification_UpdateConfig, object: nil)
        })
    }

    @IBAction func cancelTouched(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CountryViewController {
    
    func reloadData() {
        self.completedItems = countryDataHelper.findAll()
        self.filteredItems.removeAll()
        if self.searchController != nil && 	self.searchController.isActive && self.searchController.searchBar.text != "" {
            let searchText = self.searchController.searchBar.text?.lowercased()
            self.filteredItems = self.completedItems.filter {
                return ( $0.name.lowercased().contains(searchText!) || $0.code.lowercased().contains(searchText!) )
            }
        }
        self.tableView.reloadData()
        self.log.info("reloaded")
    }
    
    func find(row: Int) -> Country {
        var item: Country!
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            item = self.filteredItems[row]
        } else {
            item = self.completedItems[row]
        }
        return item
    }
}

extension CountryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.reloadData()
    }
}
extension CountryViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.reloadData()
    }
}
extension CountryViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
}

