import UIKit
import Eureka
import SwiftyUserDefaults
import XCGLogger

class SettingsViewController: FormViewController {
    let log = XCGLogger.default
    
    static let SettingsNotification_UpdateConfig = NSNotification.Name(rawValue: "SettingsNotification_UpdateConfig")
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.updateConfig), name: SettingsViewController.SettingsNotification_UpdateConfig, object: nil)

        self.title = Strings.Settings
        
        form +++ Section(Strings.Informations)
            <<< LabelRow() {
                    $0.title = String(format: Strings.AppVersion, "\(Bundle.main.releaseVersionNumber)")
                    $0.cell.textLabel?.textAlignment = .center
                }
            <<< ButtonRow(Strings.ThirdPartySoftware) {
                    $0.title = $0.tag
                }.onCellSelection { row in
                    let vc = InfoBrowserViewController()
                    super.present(UINavigationController(rootViewController: vc), animated: true, completion: {
                        let url = URL(fileURLWithPath: "\(Bundle.main.bundlePath)/ThirdPartySoftware.html")
                        vc.loadPage(url: url)
                    })
                }
            <<< ButtonRow(Strings.RatingApp) {
                $0.title = $0.tag
                }.onCellSelection { _, _ in
                    self.rateApp(appId: Bundle.main.bundleIdentifier!, completion: { success in
                        self.log.info("success = \(success)")
                    })
                }
            <<< ButtonRow(Strings.ShareFacebookPage) {
                $0.title = $0.tag
                }.onCellSelection { _, _ in
                    let vc = FacebookActivityViewController(sharingItems: ["https://www.facebook.com/radiogo"])
                    vc.completionWithItemsHandler = { activity, success, items, error in
                        if !success {
                            self.log.info("cancelled")
                        } else if activity == UIActivityType.postToFacebook {
                            self.log.info("facebook")
                        }
                    }
                    self.present(vc, animated: true, completion: nil)
                }
        
        form +++ Section(Strings.Country)
            <<< ButtonRow("CountryInputRow") {
                //$0.title = Country.dictionary[DefaultsKeys.getCountryCode()]?.name
                $0.title = "TODO"
                }.onCellSelection { _, _ in
                    self.present(UINavigationController(rootViewController: CountryViewController()), animated: true, completion: nil)
                }
    }
    
    func updateConfig() {
        self.log.info("Start")
        form.allRows.forEach {
            if let buttonRow = $0 as? ButtonRow {
                if buttonRow.tag == "CountryInputRow" {
                    self.log.info("Update CountryInputRow")
                    //buttonRow.title = Country.dictionary[DefaultsKeys.getCountryCode()]?.name
                    buttonRow.updateCell()
                }
            }
        }
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
}
