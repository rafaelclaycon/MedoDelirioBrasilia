import SwiftUI

class Mailman {

    static let supportEmail = "medodeliriosuporte@gmail.com"
    
    static let gmailMailToUrl = "googlegmail://co"
    static let outlookMailToUrl = "ms-outlook://compose"
    static let yahooMailToUrl = "ymail://mail/compose"
    static let sparkMailToUrl = "readdle-spark://compose"
    
    static var hasGmail: Bool {
        return UIApplication.shared.canOpenURL(URL(string: gmailMailToUrl)!)
    }
    
    static var hasOutlook: Bool {
        return UIApplication.shared.canOpenURL(URL(string: outlookMailToUrl)!)
    }
    
    static var hasYahooMail: Bool {
        return UIApplication.shared.canOpenURL(URL(string: yahooMailToUrl)!)
    }
    
    static var hasSpark: Bool {
        return UIApplication.shared.canOpenURL(URL(string: sparkMailToUrl)!)
    }
}
