import UIKit
import SwiftyJSON
import XCGLogger

class CountryUpdater: NSObject {
    let log = XCGLogger.default
    
    private let countryDataHelper = CountryDataHelper.shared
    private var countryArray = Array<JSON>()
    
    var size = 0

    init(version: Int) {
        super.init()
        
        let directoryPath = "\(Bundle.main.bundlePath)/\(version)"
        self.log.info("directoryPath = \(directoryPath)")
        
        let countryFilename = "\(directoryPath)/countries.json"
        if FileManager.default.fileExists(atPath: countryFilename) {
            do {
                let data = try NSData(contentsOfFile: countryFilename, options: NSData.ReadingOptions.uncached) as Data
                
                let json = JSON(data: data as Data)
                if let countryArray = json.array {
                    self.countryArray = countryArray
                    self.size = self.countryArray.count
                } else {
                    self.log.warning("countries.json is not array")
                }
            } catch {
                self.log.error(error)
            }
        } else {
            self.log.info("'\(countryFilename)' not found")
        }
        
    }

    func start() {
        for countryJSON in self.countryArray {
            let name      = countryJSON["name"].string ?? ""
            let code      = countryJSON["country_code"].string ?? ""
            let region    = countryJSON["region"].string ?? ""
            let subregion = countryJSON["subregion"].string ?? ""
            
            let country = Country(id: 0,
                                  name:   name,
                                  code:   code,
                                  region: region,
                                  subregion: subregion)
            if (countryDataHelper.find(code: code) != nil) {
                self.log.info("countryDataHelper.update(\(code))) : \( countryDataHelper.update(country, code: code) )")
            } else {
                self.log.info("countryDataHelper.insert()) : \( countryDataHelper.insert(country) )")
            }
        }
    }
}
