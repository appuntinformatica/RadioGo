import UIKit
import SwiftyJSON
import XCGLogger

class CategoryUpdater: NSObject {
    let log = XCGLogger.default
    
    private let dataHelper = CategoryDataHelper.shared
    private var array = Array<JSON>()
    
    var size = 0
    
    init(version: Int) {
        super.init()
        
        let directoryPath = "\(Bundle.main.bundlePath)/\(version)"
        self.log.info("directoryPath = \(directoryPath)")
        
        let filename = "\(directoryPath)/categories.json"
        if FileManager.default.fileExists(atPath: filename) {
            do {
                let data = try NSData(contentsOfFile: filename, options: NSData.ReadingOptions.uncached) as Data
                
                let json = JSON(data: data as Data)
                if let array = json.array {
                    self.array = array
                    self.size = self.array.count
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
        for json in self.array {
            let id          = json["id"].int64 ?? 0
            let title       = json["title"].string ?? ""
            let description = json["description"].string ?? ""
            let slug        = json["slug"].string ?? ""
            var ancestry: Int64 = 0
            if let s = json["ancestry"].string {
                ancestry = Int64(s)!
            }
            
            let item = Category(id:          id,
                                title:       title,
                                description: description,
                                slug:        slug,
                                ancestry:    ancestry
            )
            if (dataHelper.find(id: id) != nil) {
                self.log.info("dataHelper.update(\(id)) : \( dataHelper.update(item, id: id) )")
            } else {
                self.log.info("dataHelper.insert()) : \( dataHelper.insert(item) )")
            }
        }
    }
}
