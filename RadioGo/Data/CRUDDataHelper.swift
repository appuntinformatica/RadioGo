import UIKit
import SQLite
import XCGLogger

class CRUDDataHelper<T>: NSObject {
    private let log = XCGLogger.default    
    
    typealias GetterMethod = (_ row : Row)  -> T
    typealias SetterMethod = (_ item : T)  -> [Setter]
    
    private let table:   Table!
    let getter:  GetterMethod!
    let setter:  SetterMethod!
    
    init(table: Table, getter: @escaping GetterMethod, setter: @escaping SetterMethod) {
        self.table = table
        self.getter = getter
        self.setter = setter
    }
    
    func find(id: Int64) -> T? {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = self.table.filter(id == rowid)
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
    
    func findAll(table: @escaping () -> Table ) -> [T] {
        var retArray = [T]()
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            let query = table()
            
            self.log.info(query.asSQL())
            
            let items = try DB.prepare(query)
            
            for item in items {
                retArray.append( self.getter(item) )
            }
        } catch {
            self.log.error(error)
        }
        return retArray
    }
    
    func getRecordsTotal() -> Int {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let count = try DB.scalar(self.table.count)
            
            return count
        } catch {
            self.log.error(error)
        }
        return 0
    }
    
    func insert(_ item: T) -> Int64 {
        var id: Int64 = 0
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let insert = self.table.insert(self.setter(item))
            
            id = try DB.run(insert)
        } catch {
            self.log.error(error)
        }
        return id
    }

    func update(_ item: T, id: Int64) -> Int {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = self.table.filter(id == rowid)
            self.log.info(query.asSQL())
            
            return try DB.run(query.update(self.setter(item)))
        } catch {
            log.error(error)
            return -1
        }
    }
    
    func delete(id: Int64) -> Int {
        do {
            let DB = SQLiteDataStore.sharedInstance.BBDB!
            
            let query = self.table.filter(id == rowid)
            
            return try DB.run(query.delete())
        } catch {
            self.log.error(error)
            return -1
        }
    }
}
