import UIKit
import XCGLogger

class CategoriesViewController: UITableViewController {
    let log = XCGLogger.default

    let categoryDataHelper = CategoryDataHelper.shared
    let categoryStationDataHelper = CategoryStationDataHelper.shared
    
    var searchController: UISearchController!
    
    var completedItems = [ Category ]()
    var filteredItems  = [ Category ]()
    
    init() {
        super.init(style: .plain)
        self.title = Strings.Categories
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
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CategoryViewCell")
        
        let item = find(row: indexPath.row)
        
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.description
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = find(row: indexPath.row)

        let items = self.categoryStationDataHelper.find(categoryId: item.id)
        
        self.present(UINavigationController(rootViewController: StationsViewController(title: item.title, items: items)), animated: true, completion: nil)
    }
}

extension CategoriesViewController {

    func reloadData() {
        self.completedItems = categoryDataHelper.findAll()
        self.filteredItems.removeAll()
        if self.searchController != nil && 	self.searchController.isActive && self.searchController.searchBar.text != "" {
            let searchText = searchController.searchBar.text?.lowercased()
            self.filteredItems = self.completedItems.filter {
                return ( $0.title.lowercased().contains(searchText!) || $0.title.lowercased().contains(searchText!) )
            }
        }
        self.tableView.reloadData()
        self.log.info("reloaded")
    }
    
    func find(row: Int) -> Category {
        var item: Category!
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            item = self.filteredItems[row]
        } else {
            item = self.completedItems[row]
        }
        return item
    }
}

extension CategoriesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.reloadData()
    }
}
extension CategoriesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.reloadData()
    }
}
extension CategoriesViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
}
