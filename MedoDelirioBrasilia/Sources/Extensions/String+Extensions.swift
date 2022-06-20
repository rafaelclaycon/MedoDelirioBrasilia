import Foundation

extension String {

    static var empty: String {
        return ""
    }
    
    func withoutDiacritics() -> String {
        return self.folding(options: .diacriticInsensitive, locale: .current)
    }
    
    func isoStringDateToDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter.date(from: self)!
    }

}
