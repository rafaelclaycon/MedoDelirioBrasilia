//
//  TrendsService.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 06/05/25.
//

import Foundation

protocol TrendsServiceProtocol {

    // Receiving

    func shareCountStats(
        for contentType: TrendsContentType,
        in timeInterval: TrendsTimeInterval
    ) async throws -> [TopChartItem]

    func reactionsStats() async throws -> [TopChartReaction]

    func top10SoundsSharedByTheUser() -> [TopChartItem]?

    // Sending

    func sendUserPersonalTrendsToServerIfEnabled() async
}

final class TrendsService: TrendsServiceProtocol {

    public static let defaultSoundsTimeInterval: TrendsTimeInterval = .last24Hours
    public static let defaultSongsTimeInterval: TrendsTimeInterval = .lastWeek

    private let database: LocalDatabaseProtocol
    private let apiClient: APIClientProtocol

    private var defaultSoundStats: [TopChartItem]
    private var defaultSongStats: [TopChartItem]
    private var reactionStats: [TopChartReaction]

    public var soundsLastUpdate: Date = Date(timeIntervalSince1970: 0)
    public var songsLastUpdate: Date = Date(timeIntervalSince1970: 0)
    public var reactionsLastUpdate: Date = Date(timeIntervalSince1970: 0)

    // MARK: - Initializer

    init(
        database: LocalDatabaseProtocol,
        apiClient: APIClientProtocol
    ) {
        self.database = database
        self.apiClient = apiClient
        self.defaultSoundStats = []
        self.defaultSongStats = []
        self.reactionStats = []

        Task {
            await loadSoundStats(timeInterval: TrendsService.defaultSoundsTimeInterval)
            await loadSongStats(timeInterval: TrendsService.defaultSongsTimeInterval)
            await loadReactions()
        }
    }

    // MARK: - Receiving Functions

    func shareCountStats(
        for contentType: TrendsContentType,
        in timeInterval: TrendsTimeInterval
    ) async throws -> [TopChartItem] {
        switch contentType {
        case .sounds:
            switch timeInterval {
            case .last24Hours:
                if soundsLastUpdate.minutesPassed(60) {
                    await loadSoundStats(timeInterval: timeInterval)
                }
                return defaultSoundStats

            default:
                return try await apiClient.getShareCountStats(
                    for: .sounds,
                    in: timeInterval
                )
            }

        case .songs:
            switch timeInterval {
            case .lastWeek:
                if songsLastUpdate.minutesPassed(60) {
                    await loadSongStats(timeInterval: timeInterval)
                }
                return defaultSongStats

            default:
                return try await apiClient.getShareCountStats(
                    for: .songs,
                    in: timeInterval
                )
            }
        }
    }

    func reactionsStats() async throws -> [TopChartReaction] {
        if reactionsLastUpdate.minutesPassed(60) {
            await loadReactions()
        }
        return reactionStats
    }

    func top10SoundsSharedByTheUser() -> [TopChartItem]? {
        return nil
    }

    // MARK: - Sending Functions

    func sendUserPersonalTrendsToServerIfEnabled() async {
        //
    }
}

// MARK: - Internal Functions

extension TrendsService {

    private func loadSoundStats(
        timeInterval: TrendsTimeInterval
    ) async {
        do {
            defaultSoundStats = try await apiClient.getShareCountStats(
                for: .sounds,
                in: timeInterval
            )
            soundsLastUpdate = .now
        } catch {
            debugPrint(error)
        }
    }

    private func loadSongStats(
        timeInterval: TrendsTimeInterval
    ) async {
        do {
            defaultSongStats = try await apiClient.getShareCountStats(
                for: .songs,
                in: timeInterval
            )
            songsLastUpdate = .now
        } catch {
            debugPrint(error)
        }
    }

    private func loadReactions() async {
        do {
            reactionStats = try await apiClient.getReactionsStats()
            reactionsLastUpdate = .now
        } catch {
            debugPrint(error)
        }
    }
}
