//
//  Date+.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 20/06/22.
//

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

    internal func formattedDayMonthYearHoursMinutesSeconds() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt-BR")
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter.string(from: self)
    }

    internal func formattedDayMonthYearHoursMinutes() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt-BR")
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter.string(from: self)
    }

    var asRelativeDateTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date.now)
    }
}

extension Date {
    static func isDateWithinLast7Days(_ date: Date?) -> Bool {
        guard let date = date else {
            return false
        }
        
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: .now)
        
        // -8 used below to compensate for +3 hours .now has
        if let last7Days = calendar.date(byAdding: .day, value: -8, to: currentDate) {
            return calendar.isDate(date, inSameDayAs: currentDate) || date > last7Days
        }
        
        return false
    }
}

extension Date {
    var onlyDate: Date? {
        get {
            let calender = Calendar.current
            var dateComponents = calender.dateComponents([.year, .month, .day], from: self)
            dateComponents.timeZone = NSTimeZone.system
            return calender.date(from: dateComponents)
        }
    }
}

extension String {

    var asRelativeDateTime: String? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: self) else {
            return nil
        }
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .full
        return relativeFormatter.localizedString(for: date, relativeTo: Date())
    }
}

extension Date {

    func minutesPassed(_ minutes: Int) -> Bool {
        let diffComponents = Calendar.current.dateComponents([.minute], from: self, to: .now)
        let difference = diffComponents.minute!
        return difference >= minutes
    }

    static func dateAsString(addingDays daysToAdd: Int, referenceDate: Date = Date.now) -> String {
        var dayComponent = DateComponents()
        dayComponent.day = daysToAdd
        let newDate = Calendar.current.date(byAdding: dayComponent, to: referenceDate)
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "yyyy-MM-dd"
        if let newDate = newDate {
            return formatter3.string(from: newDate)
        } else {
            return .empty
        }
    }
}

extension Date {

    var minutesAndSecondsFromNow: String {
        let twoMinutesFromLastUpdate = Calendar.current.date(byAdding: .minute, value: 2, to: self)

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
