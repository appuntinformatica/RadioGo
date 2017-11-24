import UIKit
import XCGLogger

class ViewController: UITabBarController {
    let log = XCGLogger.default

    let sizeImage = CGFloat(23)
    
    let stationDataHelper = StationDataHelper.shared
    
    var favouritesVC = FavouritesViewController()
    var stationsVC:    StationsViewController!
    var categoriesVC = CategoriesViewController()
    var settingsVC   = SettingsViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        let favouritesItem = UINavigationController(rootViewController: favouritesVC)
        favouritesItem.tabBarItem = UITabBarItem(title: Strings.Favourites, image:  UIImage(named: "favourites")?.resize(self.sizeImage, self.sizeImage), tag: 1)

        let stations = self.stationDataHelper.findAll()
        self.stationsVC = StationsViewController.init(title: Strings.Stations, items: stations)
        let stationsItem = UINavigationController(rootViewController: stationsVC)
        stationsItem.tabBarItem = UITabBarItem(title: Strings.Stations, image:  UIImage(named: "stations")?.resize(self.sizeImage, self.sizeImage), tag: 1)
        
        let categoriesItem = UINavigationController(rootViewController: categoriesVC)
        categoriesItem.tabBarItem = UITabBarItem(title: Strings.Categories, image:  UIImage(named: "categories")?.resize(self.sizeImage, self.sizeImage), tag: 2)
        
        
        let settingsItem = UINavigationController(rootViewController: settingsVC)
        settingsItem.tabBarItem = UITabBarItem(title: Strings.Settings, image: UIImage(named: "settings")?.resize(self.sizeImage, self.sizeImage), tag: 3)
        
        self.viewControllers = [ favouritesItem, stationsItem, categoriesItem, settingsItem ]
    }
    
    func showUpdater() {
        let updaterVC = UpdaterViewController()
        
        UIApplication.shared.keyWindow?.rootViewController?.present(updaterVC, animated: true, completion: {
            updaterVC.startUpdater()
        })
        
        
    }
}
