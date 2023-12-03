//
//  RetroView+ViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 10/10/23.
//

import UIKit
import Combine

extension RetroView {

    class ViewModel: ObservableObject {

        @Published var topFive: [TopChartItem] = []
        @Published var shareCount: Int = 0
        @Published var mostCommonShareDay: String = "-"
        @Published var mostCommonShareDayPluralization: WordPluralization = .singular

        @Published var isShowingProcessingView = false

        @Published var exportErrors: [String] = []
        @Published var shouldProcessPostExport: Bool = false

        // Alerts
        @Published var alertTitle: String = .empty
        @Published var alertMessage: String = .empty
        @Published var showAlert: Bool = false

        let database: LocalDatabaseProtocol

        var dateFormatter: DateFormatter {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "pt-BR")
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter
        }

        init(database: LocalDatabaseProtocol = LocalDatabase.shared) {
            self.database = database
        }

        func loadInformation() {
            retrieveTopFive()
            loadShareCount()
            do {
                mostCommonShareDay = try mostCommonDay(from: database.allDatesInWhichTheUserShared()) ?? "-"
            } catch {
                print(error)
            }
        }

        func retrieveTopFive() {
            do {
                let sounds = try database.getTopSoundsSharedByTheUser(5)
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
        }

        func loadShareCount() {
            shareCount = database.totalShareCount()
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

        func save(image: UIImage) async throws {
            DispatchQueue.main.async {
                self.isShowingProcessingView = true
            }

            try await CustomPhotoAlbum.sharedInstance.save(image: image)

            DispatchQueue.main.async {
                self.isShowingProcessingView = false
            }
        }

        func showExportError() {
            alertTitle = "Houve Erros Ao Tentar Exportar as Imagens"
            alertMessage = "\(exportErrors.joined(separator: "\n\n"))\n\nTente novamente. Se persistir, informe o desenvolvedor (e-mail nas Configurações)."
            showAlert.toggle()
        }

        func analyticsString() -> String {
            let ranking = topFive.map { "\($0.rankNumber) \($0.contentName)" }
            return "\(ranking.joined(separator: ", ")); \(shareCount) compart; \(mostCommonShareDay)"
        }

        // MARK: - Static Methods

        static func shouldDisplayBanner() async -> Bool {
            guard #available(iOS 16.0, *) else { return false }
            guard await versionIsAllowedToDisplayRetro() else { return false }
            guard LocalDatabase.shared.sharedSoundsCount() > 0 else { return false }
            return true
        }

        static func versionIsAllowedToDisplayRetro(
            currentVersion: String = Versioneer.appVersion,
            network: NetworkRabbitProtocol = NetworkRabbit.shared
        ) async -> Bool {
            guard let allowedVersion = await network.retroStartingVersion() else { return false }
            return currentVersion >= allowedVersion
        }
    }
}
