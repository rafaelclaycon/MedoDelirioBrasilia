import Foundation

extension ISO8601DateFormatter {

    convenience init(_ formatOptions: Options) {
        self.init()
        self.formatOptions = formatOptions
    }

}

extension Formatter {

    static let iso8601withFractionalSeconds = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])

}

extension Date {

    var iso8601withFractionalSeconds: String { return Formatter.iso8601withFractionalSeconds.string(from: self) }

}

extension String {

    var iso8601withFractionalSeconds: Date? { return Formatter.iso8601withFractionalSeconds.date(from: self) }

}

extension Date {

    internal func toScreenString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt-BR")
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter.string(from: self)
    }
    
    var asRelativeDateTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date.now)
    }

}
