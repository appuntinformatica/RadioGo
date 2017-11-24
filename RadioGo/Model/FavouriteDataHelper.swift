import UIKit
import SQLite
import XCGLogger

typealias Favourite = (
    id:           Int64,
    stationId:    Int64,
    displayOrder: Int,
    description:  String,
    streamUrl:    String,
    imageUrl:     String
)

class FavouriteDataHelper: CRUDDataHelper<Favourite> {
    static let log = XCGLogger.default
    let log = XCGLogger.default
    
    static let shared: FavouriteDataHelper = {
        let instance = FavouriteDataHelper()
        return instance
    }()
    
    static let table        = Table("favourite")
    static let id           = Expression<Int64>("id")
    static let stationId    = Expression<Int64>("station_id")
    static let displayOrder = Expression<Int>("display_order")
    static let description  = Expression<String>("description")
    static let streamUrl    = Expression<String>("stream_url")
    static let imageUrl     = Expression<String>("image_url")
    
    typealias T = Favourite
    
    init() {
        super.init(table: FavouriteDataHelper.table,
                   getter: { (row) in
                        return Favourite(id: row[FavouriteDataHelper.id],
                                     stationId: row[FavouriteDataHelper.stationId],
                                     displayOrder: row[FavouriteDataHelper.displayOrder],
                                     description: row[FavouriteDataHelper.description],
                                     streamUrl: row[FavouriteDataHelper.streamUrl],
                                     imageUrl: row[FavouriteDataHelper.imageUrl])
                    },
                    setter: { (item) in
                        return [ FavouriteDataHelper.stationId <- item.stationId,
                                 FavouriteDataHelper.displayOrder <- item.displayOrder,
                                 FavouriteDataHelper.description <- item.description,
                                 FavouriteDataHelper.streamUrl <- item.streamUrl,
                                 FavouriteDataHelper.imageUrl <- item.imageUrl ]
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
                t.column(stationId)
                t.column(displayOrder)
                t.column(description)
                t.column(streamUrl)
                t.column(imageUrl)
            })
        } catch {
            self.log.error(error)
        }
    }
   
    func find(byStationId stationId: Int64) -> T? {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = FavouriteDataHelper.table.filter(stationId == FavouriteDataHelper.stationId)
            
            let items = try DB.prepare(query)
            
            for item in items {
                return self.getter(item)
            }
        } catch {
            self.log.error(error)
        }
        return nil
    }
    
    func findAll() -> [T] {
        return super.findAll(table: { _ in
            return FavouriteDataHelper.table.order(FavouriteDataHelper.displayOrder)
        })
    }
    
    func reorder() {
        let DB = SQLiteDataStore.sharedInstance.BBDB!
        let favourites = self.findAll()
        for (index, favourite) in favourites.enumerated() {
            do {
                let e = FavouriteDataHelper.table.filter(favourite.id == rowid)
                try DB.run(e.update(FavouriteDataHelper.displayOrder <- index))
            } catch {
                self.log.error(error)
            }
        }
    }
    
    func reorder(_ items: [Favourite]) {
        let DB = SQLiteDataStore.sharedInstance.BBDB!
        for (index, item) in items.enumerated() {
            do {
                let e = FavouriteDataHelper.table.filter(item.id == rowid)
                try DB.run(e.update(FavouriteDataHelper.displayOrder <- index))
            } catch {
                log.error(error)
            }
        }
    }
}
