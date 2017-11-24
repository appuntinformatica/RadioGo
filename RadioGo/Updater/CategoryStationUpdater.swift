import UIKit
import SwiftyJSON
import XCGLogger

class CategoryStationUpdater: NSObject {
    let log = XCGLogger.default
    
    private let dataHelper = CategoryStationDataHelper.shared
    private var dictionary = [ String: JSON ]()
    
    var size = 0
    
    init(version: Int) {
        super.init()
        
        let directoryPath = "\(Bundle.main.bundlePath)/\(version)"
        self.log.info("directoryPath = \(directoryPath)")
        
        let filename = "\(directoryPath)/categories_stations.json"
        if FileManager.default.fileExists(atPath: filename) {
            do {
                let data = try NSData(contentsOfFile: filename, options: NSData.ReadingOptions.uncached) as Data
                
                let json = JSON(data: data as Data)

                if let dictionary = json.dictionary {
                    self.dictionary = dictionary
                    self.dictionary.forEach {
                        if let array = $0.value.arrayObject {
                            self.size = self.size + array.count
                        }
                    }
                } else {
                    self.log.warning("'\(filename)' is not array")
                }
            } catch {
                self.log.error(error)
            }
        } else {
            self.log.info("'\(filename)' not found")
        }
    }
    
    func start() {
        self.dictionary.forEach {
            let categoryId = Int64($0.key)!
            if let array = $0.value.arrayObject as? Array<Int64> {
                array.forEach { stationId in
                    self.log.info("dataHelper.insert(): \(self.dataHelper.insert(categoryId: categoryId, stationId: stationId))")
                }
            }
        }
    }
}
