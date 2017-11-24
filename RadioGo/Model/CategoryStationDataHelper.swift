import UIKit
import SQLite
import XCGLogger

typealias CategoryStation = (
    categoryId : Int64,
    stationId  : Int64
)

class CategoryStationDataHelper: CRUDDataHelper<CategoryStation> {
    static let log = XCGLogger.default
    let log = XCGLogger.default
    
    static let shared: CategoryStationDataHelper = {
        let instance = CategoryStationDataHelper()
        return instance
    }()
    
    static let table      = Table("category_station")
    static let categoryId = Expression<Int64>("category_id")
    static let stationId  = Expression<Int64>("station_id")
    
    typealias T = CategoryStation
    
    init() {
        super.init(table: CategoryStationDataHelper.table,
                   getter: { (row) in
                    return CategoryStation(categoryId: row[CategoryStationDataHelper.categoryId],
                                     stationId: row[CategoryStationDataHelper.stationId])
                    },
                   setter: { (item) in
                    return [ CategoryStationDataHelper.categoryId <- item.categoryId,
                             CategoryStationDataHelper.stationId <- item.stationId ]
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
                t.column(categoryId)
                t.column(stationId)
                t.primaryKey(categoryId, stationId)
            })
        } catch {
            self.log.error(error)
        }
    }

    func find(categoryId: Int64, stationId: Int64) -> T? {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = CategoryStationDataHelper.table.filter(categoryId == CategoryStationDataHelper.categoryId && stationId == CategoryStationDataHelper.stationId)
            
            let items = try DB.prepare(query)
            
            for item in items {
                return self.getter(item)
            }
        } catch {
            self.log.error(error)
        }
        return nil
    }
    
    func find(categoryId: Int64) -> [Station] {
        var array = [Station]()
        let stationDataHelper = StationDataHelper.shared
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = CategoryStationDataHelper.table.filter(categoryId == CategoryStationDataHelper.categoryId)
            
            let items = try DB.prepare(query)
            
            
            for item in items {
                if let station = stationDataHelper.find(id: item.get(CategoryStationDataHelper.stationId)) {
                    array.append(station)
                }
            }
        } catch {
            self.log.error(error)
        }
        return array
    }
    
    func insert(categoryId: Int64, stationId: Int64) -> Bool {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let insert = CategoryStationDataHelper.table.insert([ CategoryStationDataHelper.categoryId <- categoryId,
                                                                  CategoryStationDataHelper.stationId <- stationId ])
            
            try DB.run(insert)
            return true
        } catch {
            self.log.error(error)
            return false
        }
    }
}
