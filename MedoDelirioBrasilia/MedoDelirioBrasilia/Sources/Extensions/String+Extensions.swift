import Foundation

extension String {

    func withoutDiacritics() -> String {
        return self.folding(options: .diacriticInsensitive, locale: .current)
    }

}
