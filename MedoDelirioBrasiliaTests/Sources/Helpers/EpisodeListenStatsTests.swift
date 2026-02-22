//
//  EpisodeListenStatsTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import Testing
import Foundation
@testable import MedoDelirio

struct EpisodeListenStatsTests {

    // MARK: - Helpers

    private let calendar = Calendar.current

    /// Returns a `Date` for the given year-month-day at noon, avoiding timezone edge cases.
    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    private func log(
        episodeId: String = "ep-1",
        startedAt: Date? = nil,
        durationListened: Double = 1800,
        didComplete: Bool = false
    ) -> EpisodeListenLog {
        let start = startedAt ?? date(2026, 2, 17)
        return .mock(
            episodeId: episodeId,
            startedAt: start,
            durationListened: durationListened,
            didComplete: didComplete
        )
    }

    // MARK: - Total Hours

    @Test
    func totalHoursListened_whenNoLogs_shouldReturnZero() {
        let result = EpisodeListenStats.totalHoursListened(from: [])
        #expect(result == 0)
    }

    @Test
    func totalHoursListened_whenMultipleSessions_shouldSumDurations() {
        let logs = [
            log(durationListened: 3600),
            log(durationListened: 1800),
            log(durationListened: 900),
        ]
        let result = EpisodeListenStats.totalHoursListened(from: logs)
        #expect(result == 1.75)
    }

    // MARK: - Most Played Episodes (by count)

    @Test
    func mostPlayedEpisodes_whenEmpty_shouldReturnEmpty() {
        let result = EpisodeListenStats.mostPlayedEpisodes(from: [], limit: 5)
        #expect(result.isEmpty)
    }

    @Test
    func mostPlayedEpisodes_whenMultipleEpisodes_shouldRankByCount() {
        let logs = [
            log(episodeId: "ep-a"),
            log(episodeId: "ep-a"),
            log(episodeId: "ep-a"),
            log(episodeId: "ep-b"),
            log(episodeId: "ep-b"),
            log(episodeId: "ep-c"),
        ]
        let result = EpisodeListenStats.mostPlayedEpisodes(from: logs, limit: 10)
        #expect(result.count == 3)
        #expect(result[0].episodeId == "ep-a")
        #expect(result[0].listenCount == 3)
        #expect(result[1].episodeId == "ep-b")
        #expect(result[1].listenCount == 2)
        #expect(result[2].episodeId == "ep-c")
        #expect(result[2].listenCount == 1)
    }

    @Test
    func mostPlayedEpisodes_shouldRespectLimit() {
        let logs = [
            log(episodeId: "ep-a"),
            log(episodeId: "ep-a"),
            log(episodeId: "ep-b"),
            log(episodeId: "ep-c"),
        ]
        let result = EpisodeListenStats.mostPlayedEpisodes(from: logs, limit: 2)
        #expect(result.count == 2)
        #expect(result[0].episodeId == "ep-a")
    }

    // MARK: - Most Listened Episodes (by duration)

    @Test
    func mostListenedEpisodes_whenMultipleSessionsSameEpisode_shouldSumDuration() {
        let logs = [
            log(episodeId: "ep-a", durationListened: 1000),
            log(episodeId: "ep-a", durationListened: 500),
            log(episodeId: "ep-b", durationListened: 1200),
        ]
        let result = EpisodeListenStats.mostListenedEpisodes(from: logs, limit: 10)
        #expect(result.count == 2)
        #expect(result[0].episodeId == "ep-a")
        #expect(result[0].totalSeconds == 1500)
        #expect(result[1].episodeId == "ep-b")
        #expect(result[1].totalSeconds == 1200)
    }

    // MARK: - Most Common Listen Day

    @Test
    func mostCommonListenDay_whenEmpty_shouldReturnNil() {
        let result = EpisodeListenStats.mostCommonListenDay(from: [])
        #expect(result == nil)
    }

    @Test
    func mostCommonListenDay_whenAllSameDay_shouldReturnThatDay() {
        // 2026-02-16 is a Monday
        let monday1 = date(2026, 2, 16)
        let monday2 = date(2026, 2, 23)
        let result = EpisodeListenStats.mostCommonListenDay(from: [monday1, monday2])
        #expect(result != nil)
    }

    @Test
    func mostCommonListenDay_whenMixed_shouldReturnMostFrequent() {
        // 3 Mondays vs 1 Tuesday
        let dates = [
            date(2026, 2, 16), // Monday
            date(2026, 2, 23), // Monday
            date(2026, 3, 2),  // Monday
            date(2026, 2, 17), // Tuesday
        ]
        let result = EpisodeListenStats.mostCommonListenDay(from: dates)
        #expect(result != nil)
        // The result should be the pt-BR name for Monday (segunda-feira, capitalized first letter)
        #expect(result?.lowercased().hasPrefix("segunda") == true)
    }

    // MARK: - Longest Streak

    @Test
    func longestStreak_whenNoListens_shouldReturnZero() {
        let result = EpisodeListenStats.longestStreak(from: [])
        #expect(result == 0)
    }

    @Test
    func longestStreak_whenSingleDay_shouldReturnOne() {
        let result = EpisodeListenStats.longestStreak(from: [date(2026, 2, 17)])
        #expect(result == 1)
    }

    @Test
    func longestStreak_whenConsecutiveDays_shouldReturnCorrectCount() {
        let dates = [
            date(2026, 2, 15),
            date(2026, 2, 16),
            date(2026, 2, 17),
            date(2026, 2, 18),
            date(2026, 2, 19),
        ]
        let result = EpisodeListenStats.longestStreak(from: dates)
        #expect(result == 5)
    }

    @Test
    func longestStreak_whenGapInMiddle_shouldReturnLongestRun() {
        let dates = [
            date(2026, 2, 10),
            date(2026, 2, 11),
            // gap on Feb 12
            date(2026, 2, 13),
            date(2026, 2, 14),
            date(2026, 2, 15),
        ]
        let result = EpisodeListenStats.longestStreak(from: dates)
        #expect(result == 3)
    }

    @Test
    func longestStreak_whenMultipleListensOnSameDay_shouldCountAsOneDay() {
        let dates = [
            date(2026, 2, 15),
            date(2026, 2, 15),
            date(2026, 2, 16),
            date(2026, 2, 16),
            date(2026, 2, 16),
        ]
        let result = EpisodeListenStats.longestStreak(from: dates)
        #expect(result == 2)
    }

    // MARK: - Current Streak

    @Test
    func currentStreak_whenLastListenIsToday_shouldCountBackward() {
        let today = date(2026, 2, 17)
        let dates = [
            date(2026, 2, 15),
            date(2026, 2, 16),
            date(2026, 2, 17),
        ]
        let result = EpisodeListenStats.currentStreak(from: dates, today: today)
        #expect(result == 3)
    }

    @Test
    func currentStreak_whenLastListenIsYesterday_shouldStillCount() {
        let today = date(2026, 2, 17)
        let dates = [
            date(2026, 2, 14),
            date(2026, 2, 15),
            date(2026, 2, 16),
        ]
        let result = EpisodeListenStats.currentStreak(from: dates, today: today)
        #expect(result == 3)
    }

    @Test
    func currentStreak_whenLastListenIsTwoDaysAgo_shouldReturnZero() {
        let today = date(2026, 2, 17)
        let dates = [
            date(2026, 2, 14),
            date(2026, 2, 15),
        ]
        let result = EpisodeListenStats.currentStreak(from: dates, today: today)
        #expect(result == 0)
    }

    @Test
    func currentStreak_whenNoListens_shouldReturnZero() {
        let today = date(2026, 2, 17)
        let result = EpisodeListenStats.currentStreak(from: [], today: today)
        #expect(result == 0)
    }
}
