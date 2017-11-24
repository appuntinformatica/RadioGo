import UIKit
import SwiftyUserDefaults
import XCGLogger
extension DefaultsKeys {
    static let log = XCGLogger.default

    private static let countryCode = DefaultsKey<String>("countryCode")
    static func setCountryCode(_ value: String) {
        Defaults[DefaultsKeys.countryCode] = value
    }
    static func getCountryCode() -> String {
        if Defaults[DefaultsKeys.countryCode] == "" {
            self.log.info("countryCode is empty")
            Defaults[DefaultsKeys.countryCode] = ""
            self.log.info("--> \(Defaults[DefaultsKeys.countryCode])")
        }
        return Defaults[DefaultsKeys.countryCode]
    }    
}
