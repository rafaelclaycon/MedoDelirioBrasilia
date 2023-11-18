//
//  SoundsOfTheYearViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 10/10/23.
//

import Foundation
import Combine

class SoundsOfTheYearViewViewModel: ObservableObject {

    @Published var topFive: [TopChartItem] = []
    @Published var shareCount: Int = 0
    @Published var mostCommonShareDay: String = "-"
    @Published var mostCommonShareDayPluralization: WordPluralization = .singular

    @Published var selectedSocialNetwork = IntendedVideoDestination.twitter.rawValue
    @Published var isShowingProcessingView = false

    // Alerts
    @Published var alertTitle: String = .empty
    @Published var alertMessage: String = .empty
    @Published var showAlert: Bool = false

    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt-BR")
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter
    }

    static func shouldDisplayBanner() -> Bool {
        guard #available(iOS 16.0, *) else { return false }
        guard LocalDatabase.shared.sharedSoundsCount() > 0 else { return false }
        return true
    }

    func retrieveTopFive() {
        do {
            let sounds = try LocalDatabase.shared.getTopSoundsSharedByTheUser(5)
            for i in sounds.indices {
                topFive.append(
                    .init(
                        rankNumber: "\(i+1)",
                        contentName: sounds[i].contentName
                    )
                )
            }
        } catch {
            print("Deu ruim")
        }
//        do {
//            let sounds = try LocalDatabase.shared.sounds(
//                allowSensitive: true,
//                favoritesOnly: false
//            )
//            for i in 1...5 {
//                topFive.append(
//                    .init(
//                        rankNumber: "\(i)",
//                        contentName: sounds.randomElement()!.title
//                    )
//                )
//            }
//        } catch {
//            print("Deu ruim")
//        }
    }

    func loadShareCount() {
        shareCount = LocalDatabase.shared.totalShareCount()
    }

    func dayOfTheWeek(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    func mostCommonDay(from dates: [Date]) -> String? {
        let dayOfTheWeekArray = dates.map { dayOfTheWeek(from: $0) }

        var stringCounts = [String: Int]()

        for str in dayOfTheWeekArray {
            if let count = stringCounts[str] {
                stringCounts[str] = count + 1
            } else {
                stringCounts[str] = 1
            }
        }

        let stringCountTuples = stringCounts.map { (key: $0.key, value: $0.value) }

        let sortedTuples = stringCountTuples.sorted { $0.value > $1.value }

        for (string, count) in sortedTuples {
            print("\(string): \(count) times")
        }

        if let firstTuple = sortedTuples.first {
            let topValue = firstTuple.1
            let topItems = sortedTuples.filter { $0.value == topValue }

            if topItems.count > 1 {
                mostCommonShareDayPluralization = .plural
            } else {
                mostCommonShareDayPluralization = .singular
            }

            let result = topItems.map { key, value in
                value == 1 ? key : "\(key)"
            }.joined(separator: ", ")

            print(result)
            return result
        } else {
            return nil
        }
    }
}
