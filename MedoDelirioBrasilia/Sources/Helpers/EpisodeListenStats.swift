//
//  EpisodeListenStats.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import Foundation

enum EpisodeListenStats {

    // MARK: - Duration

    static func totalHoursListened(from logs: [EpisodeListenLog]) -> Double {
        logs.reduce(0) { $0 + $1.durationListened } / 3600.0
    }

    // MARK: - Rankings

    static func mostPlayedEpisodes(
        from logs: [EpisodeListenLog],
        limit: Int
    ) -> [(episodeId: String, listenCount: Int)] {
        let grouped = Dictionary(grouping: logs, by: \.episodeId)
        return grouped
            .map { (episodeId: $0.key, listenCount: $0.value.count) }
            .sorted { $0.listenCount > $1.listenCount }
            .prefix(limit)
            .map { $0 }
    }

    static func mostListenedEpisodes(
        from logs: [EpisodeListenLog],
        limit: Int
    ) -> [(episodeId: String, totalSeconds: Double)] {
        let grouped = Dictionary(grouping: logs, by: \.episodeId)
        return grouped
            .map { (episodeId: $0.key, totalSeconds: $0.value.reduce(0) { $0 + $1.durationListened }) }
            .sorted { $0.totalSeconds > $1.totalSeconds }
            .prefix(limit)
            .map { $0 }
    }

    // MARK: - Day of Week

    static func mostCommonListenDay(from dates: [Date]) -> String? {
        guard !dates.isEmpty else { return nil }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt-BR")
        formatter.dateFormat = "EEEE"

        var dayCounts: [String: Int] = [:]
        for date in dates {
            let dayName = formatter.string(from: date)
            dayCounts[dayName, default: 0] += 1
        }

        guard let mostCommon = dayCounts.max(by: { $0.value < $1.value })?.key else {
            return nil
        }
        return mostCommon.prefix(1).uppercased() + mostCommon.dropFirst()
    }

    // MARK: - Streaks

    static func longestStreak(from dates: [Date]) -> Int {
        let uniqueDays = uniqueCalendarDays(from: dates)
        guard !uniqueDays.isEmpty else { return 0 }
        return longestConsecutiveRun(in: uniqueDays)
    }

    static func currentStreak(from dates: [Date], today: Date = Date()) -> Int {
        let uniqueDays = uniqueCalendarDays(from: dates)
        guard !uniqueDays.isEmpty else { return 0 }

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: today)
        let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart)!

        guard let lastDay = uniqueDays.last,
              lastDay == todayStart || lastDay == yesterdayStart else {
            return 0
        }

        var streak = 1
        for i in stride(from: uniqueDays.count - 2, through: 0, by: -1) {
            let expected = calendar.date(byAdding: .day, value: -1, to: uniqueDays[i + 1])!
            if uniqueDays[i] == expected {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    /// Reusable for bookmark streaks or any date-based streak.
    static func bookmarkStreak(from dates: [Date], today: Date = Date()) -> Int {
        currentStreak(from: dates, today: today)
    }

    // MARK: - Private Helpers

    private static func uniqueCalendarDays(from dates: [Date]) -> [Date] {
        let calendar = Calendar.current
        let daySet = Set(dates.map { calendar.startOfDay(for: $0) })
        return daySet.sorted()
    }

    private static func longestConsecutiveRun(in sortedDays: [Date]) -> Int {
        let calendar = Calendar.current
        var longest = 1
        var current = 1

        for i in 1..<sortedDays.count {
            let expected = calendar.date(byAdding: .day, value: 1, to: sortedDays[i - 1])!
            if sortedDays[i] == expected {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        return longest
    }
}
