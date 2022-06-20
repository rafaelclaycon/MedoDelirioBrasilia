import Foundation

extension Date {

    internal func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt-BR")
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter.string(from: self)
    }

}
