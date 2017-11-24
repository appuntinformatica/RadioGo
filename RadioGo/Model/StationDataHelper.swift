import UIKit
import SQLite
import XCGLogger

typealias Station = (
    id         : Int64,
    name       : String,
    country    : String,
    imageUrl   : String,
    streamUrl  : String,
    bitrate    : Int64
)

class StationDataHelper: CRUDDataHelper<Station> {
    static let log = XCGLogger.default
    let log = XCGLogger.default
    
    static let shared: StationDataHelper = {
        let instance = StationDataHelper()
        return instance
    }()
    
    static let table     = Table("station")
    static let id        = Expression<Int64>("id")
    static let name      = Expression<String>("name")
    static let country   = Expression<String>("country")
    static let imageUrl  = Expression<String>("image_url")
    static let streamUrl = Expression<String>("stream_url")
    static let bitrate   = Expression<Int64>("bitrate")
    
    typealias T = Station
    
    init() {
        super.init(table: StationDataHelper.table,
                   getter: { (row) in
                    return Station(id: row[StationDataHelper.id],
                                    name: row[StationDataHelper.name],
                                    country: row[StationDataHelper.country],
                                    imageUrl: row[StationDataHelper.imageUrl],
                                    streamUrl: row[StationDataHelper.streamUrl],
                                    bitrate: row[StationDataHelper.bitrate])
                },
                   setter: { (item) in
                    return [StationDataHelper.id <- item.id,
                            StationDataHelper.name <- item.name,
                            StationDataHelper.country <- item.country,
                            StationDataHelper.imageUrl <- item.imageUrl,
                            StationDataHelper.streamUrl <- item.streamUrl,
                            StationDataHelper.bitrate <- item.bitrate ]
                }
        )
    }
    
    static func createTable() {
        let DB = SQLiteDataStore.sharedInstance.BBDB!
        var exists = false
        do {
            exists = try DB.scalar(table.exists)
        } catch { }
        self.log.info("exists = \(exists)")
        do {
            try DB.run( table.create(ifNotExists: true) {t in
                t.column(id, primaryKey: true)
                t.column(name)
                t.column(country)
                t.column(imageUrl)
                t.column(streamUrl)
                t.column(bitrate)
            })
        } catch {
            self.log.error(error)
        }
    }
    
    func findAll() -> [T] {
        return super.findAll(table: { _ in
            return StationDataHelper.table.order(StationDataHelper.name)
        })
    }
    
    func findAll(country: String) -> [T] {
        return super.findAll(table: { _ in
            return StationDataHelper.table.filter(StationDataHelper.country == country).order(StationDataHelper.name)
        })
    }
}
