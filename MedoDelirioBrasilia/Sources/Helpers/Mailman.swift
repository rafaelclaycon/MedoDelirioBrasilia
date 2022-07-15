import MessageUI
import UIKit

class Mailman {

    private static let gmailMailToUrl = "googlegmail://co"
    private static let outlookMailToUrl = "ms-outlook://compose"
    private static let yahooMailToUrl = "ymail://mail/compose"
    private static let sparkMailToUrl = "readdle-spark://compose"
    
//    static func sendEmail(to recipientEmail: String, withSubject subject: String, andBody body: String) {
//        // Show default mail composer
//        if MFMailComposeViewController.canSendMail() {
//            let mail = MFMailComposeViewController()
//            //mail.mailComposeDelegate = self
//            mail.setToRecipients([recipientEmail])
//            mail.setSubject(subject)
//            mail.setMessageBody(body, isHTML: false)
//            
//            present(mail, animated: true)
//        
//        // Show third party email composer if default Mail app is not present
//        } else if let emailUrl = createEmailUrl(to: recipientEmail, subject: subject, body: body) {
//            UIApplication.shared.open(emailUrl)
//        }
//    }
    
    private static func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let gmailUrl = URL(string: "\(gmailMailToUrl)?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "\(outlookMailToUrl)?to=\(to)&subject=\(subjectEncoded)")
        let yahooMail = URL(string: "\(yahooMailToUrl)?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "\(sparkMailToUrl)?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
        
        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }
        
        return defaultUrl
    }
    
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
