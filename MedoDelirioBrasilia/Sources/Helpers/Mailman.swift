import SwiftUI

class Mailman {

    private static let recipient = "medodeliriosuporte@gmail.com"
    
    private static let defaultSubject = "Problema/sugestão no app iOS \(Versioneer.appVersion) Build \(Versioneer.buildVersionNumber)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    private static let defaultMessage = "Para um problema, inclua passos para reproduzir e prints se possível.".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    
    private static let gmailMailToUrl = "googlegmail://co"
    private static let outlookMailToUrl = "ms-outlook://compose"
    private static let yahooMailToUrl = "ymail://mail/compose"
    private static let sparkMailToUrl = "readdle-spark://compose"
    
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
    
    @ViewBuilder static func getMailClientOptions() -> some View {
        Button("Mail") {
            let mailToString = "mailto:\(recipient)?subject=\(defaultSubject)&body=\(defaultMessage)"
            guard let mailToUrl = URL(string: mailToString) else {
                return
            }
            UIApplication.shared.open(mailToUrl)
        }
        
        if Mailman.hasGmail {
            Button("Gmail") {
                let mailToString = "\(gmailMailToUrl)?to=\(recipient)?subject=\(defaultSubject)&body=\(defaultMessage)"
                guard let mailToUrl = URL(string: mailToString) else {
                    return
                }
                UIApplication.shared.open(mailToUrl)
            }
        }
        
        if Mailman.hasOutlook {
            Button("Outlook") {
                let mailToString = "\(outlookMailToUrl)?to=\(recipient)?subject=\(defaultSubject)&body=\(defaultMessage)"
                guard let mailToUrl = URL(string: mailToString) else {
                    return
                }
                UIApplication.shared.open(mailToUrl)
            }
        }
        
        if Mailman.hasYahooMail {
            Button("Yahoo Mail") {
                let mailToString = "\(yahooMailToUrl)?to=\(recipient)?subject=\(defaultSubject)&body=\(defaultMessage)"
                guard let mailToUrl = URL(string: mailToString) else {
                    return
                }
                UIApplication.shared.open(mailToUrl)
            }
        }
        
        if Mailman.hasSpark {
            Button("Spark") {
                let mailToString = "\(sparkMailToUrl)?recipient=\(recipient)?subject=\(defaultSubject)&body=\(defaultMessage)"
                guard let mailToUrl = URL(string: mailToString) else {
                    return
                }
                UIApplication.shared.open(mailToUrl)
            }
        }
    }

}
