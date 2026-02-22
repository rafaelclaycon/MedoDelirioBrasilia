//
//  EpisodeListenStoreTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import Testing
import Foundation
@testable import MedoDelirio

struct EpisodeListenStoreTests {

    private var sut: EpisodeListenStore
    private var fakeDatabase: FakeLocalDatabase

    init() {
        fakeDatabase = FakeLocalDatabase()
        sut = EpisodeListenStore(database: fakeDatabase)
    }

    // MARK: - Helpers

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    // MARK: - Tests

    @Test
    func recordSession_shouldPersistToDatabase() {
        let start = date(2026, 2, 17)
        sut.recordSession(
            episodeId: "ep-1",
            startedAt: start,
            endedAt: start.addingTimeInterval(1800),
            durationListened: 1800,
            didComplete: false
        )

        #expect(fakeDatabase.episodeListenLogs.count == 1)
        #expect(fakeDatabase.episodeListenLogs[0].episodeId == "ep-1")
        #expect(fakeDatabase.episodeListenLogs[0].durationListened == 1800)
        #expect(fakeDatabase.episodeListenLogs[0].didComplete == false)
    }

    @Test
    func recordSession_whenDurationIsZero_shouldNotPersist() {
        let start = date(2026, 2, 17)
        sut.recordSession(
            episodeId: "ep-1",
            startedAt: start,
            endedAt: start,
            durationListened: 0,
            didComplete: false
        )

        #expect(fakeDatabase.episodeListenLogs.isEmpty)
    }

    @Test
    func recordSession_shouldAccumulateMultipleSessions() {
        let start1 = date(2026, 2, 17)
        let start2 = date(2026, 2, 18)

        sut.recordSession(
            episodeId: "ep-1",
            startedAt: start1,
            endedAt: start1.addingTimeInterval(1800),
            durationListened: 1800,
            didComplete: false
        )
        sut.recordSession(
            episodeId: "ep-2",
            startedAt: start2,
            endedAt: start2.addingTimeInterval(3600),
            durationListened: 3600,
            didComplete: true
        )

        #expect(fakeDatabase.episodeListenLogs.count == 2)

        let totalDuration = fakeDatabase.episodeListenLogs.reduce(0) { $0 + $1.durationListened }
        #expect(totalDuration == 5400)
    }

    @Test
    func allLogs_shouldReturnAllRecordedSessions() {
        let start = date(2026, 2, 17)
        sut.recordSession(
            episodeId: "ep-1",
            startedAt: start,
            endedAt: start.addingTimeInterval(900),
            durationListened: 900,
            didComplete: false
        )
        sut.recordSession(
            episodeId: "ep-2",
            startedAt: start,
            endedAt: start.addingTimeInterval(600),
            durationListened: 600,
            didComplete: false
        )

        let logs = sut.allLogs()
        #expect(logs.count == 2)
    }

    @Test
    func logs_forSpecificEpisode_shouldFilterCorrectly() {
        let start = date(2026, 2, 17)
        sut.recordSession(
            episodeId: "ep-1",
            startedAt: start,
            endedAt: start.addingTimeInterval(900),
            durationListened: 900,
            didComplete: false
        )
        sut.recordSession(
            episodeId: "ep-2",
            startedAt: start,
            endedAt: start.addingTimeInterval(600),
            durationListened: 600,
            didComplete: false
        )
        sut.recordSession(
            episodeId: "ep-1",
            startedAt: start,
            endedAt: start.addingTimeInterval(300),
            durationListened: 300,
            didComplete: true
        )

        let ep1Logs = sut.logs(for: "ep-1")
        let ep2Logs = sut.logs(for: "ep-2")

        #expect(ep1Logs.count == 2)
        #expect(ep2Logs.count == 1)
        #expect(ep1Logs.allSatisfy { $0.episodeId == "ep-1" })
    }

    @Test
    func allListenDates_shouldReturnStartDates() {
        let start1 = date(2026, 2, 17)
        let start2 = date(2026, 2, 18)

        sut.recordSession(
            episodeId: "ep-1",
            startedAt: start1,
            endedAt: start1.addingTimeInterval(900),
            durationListened: 900,
            didComplete: false
        )
        sut.recordSession(
            episodeId: "ep-2",
            startedAt: start2,
            endedAt: start2.addingTimeInterval(600),
            durationListened: 600,
            didComplete: false
        )

        let dates = sut.allListenDates()
        #expect(dates.count == 2)
        #expect(dates.contains(start1))
        #expect(dates.contains(start2))
    }
}
