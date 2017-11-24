import UIKit
import SQLite
import XCGLogger

typealias Country = (
    id        : Int64,
    name      : String,
    code      : String,
    region    : String,
    subregion : String
)

class CountryDataHelper: CRUDDataHelper<Country> {
    static let log = XCGLogger.default
    let log = XCGLogger.default
    
    static let shared: CountryDataHelper = {
        let instance = CountryDataHelper()
        return instance
    }()
    
    static let table     = Table("country")
    static let id        = Expression<Int64>("id")
    static let name      = Expression<String>("name")
    static let code      = Expression<String>("code")
    static let region    = Expression<String>("region")
    static let subregion = Expression<String>("subregion")
    
    
    typealias T = Country
    
    init() {
        super.init(table: CountryDataHelper.table,
                getter: { (row) in
                    return Country(id: row[CountryDataHelper.id],
                                    name: row[CountryDataHelper.name],
                                    code: row[CountryDataHelper.code],
                                    region: row[CountryDataHelper.region],
                                    subregion: row[CountryDataHelper.subregion])
                    },
                setter: { (item) in
                    return [CountryDataHelper.id <- item.id,
                            CountryDataHelper.name <- item.name,
                            CountryDataHelper.code <- item.code,
                            CountryDataHelper.region <- item.region,
                            CountryDataHelper.subregion <- item.subregion ]
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
                t.column(id)
                t.column(name)
                t.column(code, primaryKey: true)
                t.column(region)
                t.column(subregion)
            })
        } catch {
            self.log.error(error)
        }
    }
    
    func findAll() -> [T] {
        return super.findAll(table: { _ in
            return CountryDataHelper.table.order(CountryDataHelper.name)
        })
    }
    
    func find(code: String) -> T? {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = CountryDataHelper.table.filter(code == CountryDataHelper.code)
            self.log.info(query.asSQL())
            
            let items = try DB.prepare(query)
            
            for item in items {
                return self.getter(item)
            }
        } catch {
            self.log.error(error)
        }
        return nil
    }

    func update(_ item: T, code: String) -> Int {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = CountryDataHelper.table.filter(CountryDataHelper.code == code)
            self.log.info(query.asSQL())
            
            return try DB.run(query.update(self.setter(item)))
        } catch {
            log.error(error)
            return -1
        }
    }
}
