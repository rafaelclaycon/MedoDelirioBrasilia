import Foundation

extension String {

    static var empty: String {
        return ""
    }
    
    func withoutDiacritics() -> String {
        return self.folding(options: .diacriticInsensitive, locale: .current)
    }

}
