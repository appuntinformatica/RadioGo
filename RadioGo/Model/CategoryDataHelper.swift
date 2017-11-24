import UIKit
import SQLite
import XCGLogger

typealias Category = (
    id          : Int64,
    title       : String,
    description : String,
    slug        : String,
    ancestry    : Int64
)

class CategoryDataHelper: CRUDDataHelper<Category> {
    static let log = XCGLogger.default
    let log = XCGLogger.default
    
    static let shared: CategoryDataHelper = {
        let instance = CategoryDataHelper()
        return instance
    }()
    
    static let table       = Table("category")
    static let id          = Expression<Int64>("id")
    static let title       = Expression<String>("title")
    static let description = Expression<String>("description")
    static let slug        = Expression<String>("slug")
    static let ancestry    = Expression<Int64>("ancestry")
    
    typealias T = Category
    
    init() {
        super.init(table: CategoryDataHelper.table,
                   getter: { (row) in
                    return Category(id: row[CategoryDataHelper.id],
                                     title: row[CategoryDataHelper.title],
                                     description: row[FavouriteDataHelper.description],
                                     slug: row[CategoryDataHelper.slug],
                                     ancestry: row[CategoryDataHelper.ancestry])
                    },
                   setter: { (item) in
                    return [ CategoryDataHelper.title <- item.title,
                             CategoryDataHelper.description <- item.description,
                             CategoryDataHelper.slug <- item.slug,
                             CategoryDataHelper.ancestry <- item.ancestry ]
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
                t.column(title)
                t.column(description)
                t.column(slug)
                t.column(ancestry)
            })
        } catch {
            self.log.error(error)
        }
    }

    func findAll() -> [T] {
        return super.findAll(table: { _ in
            return CategoryDataHelper.table.filter(CategoryDataHelper.ancestry != 0).order(CategoryDataHelper.title)
        })
    }
}
