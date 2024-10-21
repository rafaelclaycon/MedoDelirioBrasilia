import SwiftUI

extension String {

    static var empty: String {
        return ""
    }
    
    func withoutDiacritics() -> String {
        return self.folding(options: .diacriticInsensitive, locale: .current)
    }
    
    func toPastelColor() -> Color {
        switch self {
        case "pastelPurple":
            return .pastelPurple
        case "pastelBabyBlue":
            return .pastelBabyBlue
        case "pastelBrightGreen":
            return .pastelBrightGreen
        case "pastelYellow":
            return .pastelYellow
        case "pastelOrange":
            return .pastelOrange
        case "pastelPink":
            return .pastelPink
        case "pastelGray":
            return .pastelGray
        case "pastelRoyalBlue":
            return .pastelRoyalBlue
        case "pastelMutedGreen":
            return .pastelMutedGreen
        case "pastelRed":
            return .pastelRed
        case "pastelBeige":
            return .pastelBeige
        default:
            return .white
        }
    }
}

extension String {

    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            return dateFormatter.string(from: date)
        } else {
            return "Formato de data inválido"
        }
    }
}

extension String {

    var minutesAndSecondsFromNow: String {
        guard let date = self.iso8601withFractionalSeconds else { return "" }
        let twoMinutesFromLastUpdate = Calendar.current.date(byAdding: .minute, value: 2, to: date)

        guard let endDate = twoMinutesFromLastUpdate else { return "" }
        let components = Calendar.current.dateComponents([.minute, .second], from: .now, to: endDate)

        guard let minutes = components.minute, let seconds = components.second else { return "" }
        if minutes > 0 {
            return "\(minutes) minuto e \(seconds) segundos"
        } else {
            return seconds > 1 ? "\(seconds) segundos" : "1 segundo"
        }
    }
}

extension String {

    func toColor() -> Color {
        switch self {
        case "red":
            return .red
        case "orange":
            return .orange
        case "yellow":
            return .yellow
        case "black":
            return .black
        case "blue":
            return .blue
        case "brown":
            return .brown
        case "gray":
            return .gray
        case "green":
            return .green
        case "purple":
            return .purple
        case "pink":
            return .pink
        case "mint":
            return .mint
        case "teal":
            return .teal
        case "cyan":
            return .cyan
        case "indigo":
            return .indigo
        default:
            return .white
        }
    }
}
