//
//  NetworkRabbit+ShareStats.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 02/03/25.
//

import Foundation

extension NetworkRabbit {

    func getShareCountStats(
        for contentType: TrendsContentType,
        in timeInterval: TrendsTimeInterval
    ) async throws -> [TopChartItem] {
        var url: URL

        let keyword = contentType == .sounds ? "sound" : "song"

        switch timeInterval {
        case .last24Hours:
            let refDate: String = Date.dateAsString(addingDays: -1)
            url = URL(string: serverPath + "v3/\(keyword)-share-count-stats-from/\(refDate)")!

        case .last3Days:
            let refDate: String = Date.dateAsString(addingDays: -3)
            url = URL(string: serverPath + "v3/\(keyword)-share-count-stats-from/\(refDate)")!

        case .lastWeek:
            let refDate: String = Date.dateAsString(addingDays: -7)
            url = URL(string: serverPath + "v3/\(keyword)-share-count-stats-from/\(refDate)")!

        case .lastMonth:
            let refDate: String = Date.dateAsString(addingDays: -30)
            url = URL(string: serverPath + "v3/\(keyword)-share-count-stats-from/\(refDate)")!

        case .year2025:
            url = URL(string: serverPath + "v3/\(keyword)-share-count-stats-from-to/2025-01-01/2025-12-31")!

        case .year2024:
            url = URL(string: serverPath + "v3/\(keyword)-share-count-stats-from-to/2024-01-01/2024-12-31")!

        case .year2023:
            url = URL(string: serverPath + "v3/\(keyword)-share-count-stats-from-to/2023-01-01/2023-12-31")!

        case .year2022:
            url = URL(string: serverPath + "v3/\(keyword)-share-count-stats-from-to/2022-01-01/2022-12-31")!

        case .allTime:
            url = URL(string: serverPath + "v3/\(keyword)-share-count-stats-all-time")!
        }

        return try await NetworkRabbit.shared.get(from: url)
    }

    func getReactionsStats() async throws -> [TopChartReaction] {
        let url = URL(string: serverPath + "v3/reaction-popularity-stats")!
        let serverStats: [TopChartReactionDTO] = try await NetworkRabbit.shared.get(from: url)
        return NetworkRabbit.groupedStats(from: serverStats)
    }

    public static func groupedStats(from stats: [TopChartReactionDTO]) -> [TopChartReaction] {
        guard !stats.isEmpty else { return [] }

        let grouped = Dictionary(grouping: stats) { $0.reaction.title }

        let merged = grouped.map { (title, group) -> TopChartReaction in
            let first = group.first!

            let descriptions = group.compactMap { $0.description }

            var newDescription = ""
            if descriptions.count == 1 {
                newDescription = descriptions[0]
            } else if descriptions.count == 2 {
                newDescription = "\(descriptions[0]) & \(descriptions[1])"
            } else if descriptions.count > 2 {
                let allButLast = descriptions.dropLast().joined(separator: ", ")
                let last = descriptions.last!
                newDescription = "\(allButLast) & \(last)"
            }

            return TopChartReaction(
                id: UUID().uuidString,
                position: first.position,
                reaction: first.reaction.reaction,
                description: newDescription
            )
        }

        return merged.sorted { $0.position < $1.position }
    }
}
