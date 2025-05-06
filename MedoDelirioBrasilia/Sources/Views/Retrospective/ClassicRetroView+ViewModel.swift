//
//  ClassicRetroView+ViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 10/10/23.
//

import UIKit
import Combine

extension ClassicRetroView {

    @MainActor
    class ViewModel: ObservableObject {

        @Published var isLoading: Bool = true
        @Published var topFive: [TopChartItem] = []
        @Published var shareCount: Int = 0
        @Published var mostCommonShareDay: String = "-"
        @Published var mostCommonShareDayPluralization: WordPluralization = .singular

        @Published var isShowingProcessingView = false

        @Published var exportErrors: [String] = []
        @Published var shouldProcessPostExport: Bool = false

        // Alerts
        @Published var alertTitle: String = ""
        @Published var alertMessage: String = ""
        @Published var showAlert: Bool = false

        private let database: LocalDatabaseProtocol

        // MARK: - Computed Properties

        var dateFormatter: DateFormatter {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "pt-BR")
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter
        }

        // MARK: - Initializer

        init(
            database: LocalDatabaseProtocol = LocalDatabase.shared
        ) {
            self.database = database
        }
    }
}

// MARK: - User Actions

extension ClassicRetroView.ViewModel {

    func onViewLoaded() async {
        isLoading = true

        retrieveTopFive()
        loadShareCount()
        do {
            mostCommonShareDay = try mostCommonDay(from: database.allDatesInWhichTheUserShared()) ?? "-"
        } catch {
            print(error)
        }

        isLoading = false
    }
}

// MARK: - Functions

extension ClassicRetroView.ViewModel {

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
        isShowingProcessingView = true

        try await CustomPhotoAlbum.shared.save(image: image)

        isShowingProcessingView = false
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
}

// MARK: - Static Methods

extension ClassicRetroView.ViewModel {

    static func shouldDisplayBanner() async -> Bool {
        guard await versionIsAllowedToDisplayRetro() else { return false }
        guard LocalDatabase.shared.sharedSoundsCount() > 0 else { return false }
        return true
    }

    static func versionIsAllowedToDisplayRetro(
        currentVersion: String = Versioneer.appVersion,
        network: APIClientProtocol = APIClient.shared
    ) async -> Bool {
//        guard let allowedVersion = await network.retroStartingVersion() else { return false }
//        return currentVersion >= allowedVersion
        return false
    }
}
