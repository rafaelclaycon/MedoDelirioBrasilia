import Foundation

extension Date {

    func toRelativeDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter.string(from: self).lowercased()
    }

}
