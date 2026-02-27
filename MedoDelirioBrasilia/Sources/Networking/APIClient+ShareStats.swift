//
//  APIClient+ShareStats.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 02/03/25.
//

import Foundation

extension APIClient {

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

        case .last3Months:
            let refDate: String = Date.dateAsString(addingDays: -90)
            url = URL(string: serverPath + "v3/\(keyword)-share-count-stats-from/\(refDate)")!

        case .year2026:
            url = URL(string: serverPath + "v3/\(keyword)-share-count-stats-from-to/2026-01-01/2026-12-31")!

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

        return try await self.get(from: url)
    }

    func top3Reactions() async throws -> [Reaction] {
        let url = URL(string: serverPath + "v4/top-3-reactions")!
        let reactions: [ReactionDTO] = try await self.get(from: url)
        return reactions.map { $0.reaction }
    }

    func getReactionsStats() async throws -> [TopChartReaction] {
        let url = URL(string: serverPath + "v3/reaction-popularity-stats")!
        let serverStats: [TopChartReactionDTO] = try await self.get(from: url)
        return APIClient.groupedStats(from: serverStats)
    }

    public static func groupedStats(from stats: [TopChartReactionDTO]) -> [TopChartReaction] {
        guard !stats.isEmpty else { return [] }

        // Filter out invalid reactions before processing
        let validStats = stats.filter { isValidReaction($0) }
        guard !validStats.isEmpty else { return [] }

        let grouped = Dictionary(grouping: validStats) { $0.reaction.title }

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

    /// Validates if a TopChartReactionDTO has all required fields populated
    private static func isValidReaction(_ reactionDTO: TopChartReactionDTO) -> Bool {
        let reaction = reactionDTO.reaction

        // Check if essential fields are not null and not empty
        guard let id = reaction.id, !id.isEmpty,
              let title = reaction.title, !title.isEmpty,
              let image = reaction.image, !image.isEmpty,
              let lastUpdate = reaction.lastUpdate, !lastUpdate.isEmpty else {
            return false
        }

        return true
    }
}
