//
//  FakeLocalDatabase.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Claycon Schmitt on 02/02/23.
//

@testable import MedoDelirio
import Foundation

enum CustomSQLiteError: Error {

    case databaseError(message: String)
    case queryError(message: String)
}

class FakeLocalDatabase: LocalDatabaseProtocol {

    var folders = [UserFolder]()
    var contentInsideFolder = [UserFolderContent]()
    var unsuccessfulUpdatesToReturn: [UpdateEvent]? = nil
    var errorToThrowOnInsertUpdateEvent: CustomSQLiteError? = nil

    var didCallInsertSound = false
    var didCallUpdateSound = false
    var didCallDeleteSound = false
    var didCallSetIsFromServerOnSoundId = false

    var didCallInsertAuthor = false
    var didCallUpdateAuthor = false
    var didCallDeleteAuthor = false

    var didCallInsertSong = false
    var didCallUpdateSong = false
    var didCallDeleteSong = false
    var didCallSetIsFromServerOnSongId = false

    var didCallInsertGenre = false
    var didCallUpdateGenre = false
    var didCallDeleteGenre = false

    var didCallInsertUpdateEvent = false
    var didCallMarkAsSucceeded = false
    var didCallUnsuccessfulUpdates = false

    var didCallInsertSyncLog = false

    var topSharedSounds: [TopChartItem] = []
    var shareCount: Int = 0
    var shareDates: [Date] = []
    var numberOfTimesInsertUpdateEventWasCalled = 0
    var preexistingUpdates: [UpdateEvent] = []

    var didCallDeletePinnedReaction = false

    // Sound

    func insert(sound newSound: MedoDelirio.Sound) throws {
        didCallInsertSound = true
    }

    func update(sound updatedSound: MedoDelirio.Sound) throws {
        didCallUpdateSound = true
    }

    func delete(soundId: String) throws {
        didCallDeleteSound = true
    }

    func setIsFromServer(to value: Bool, onSoundId soundId: String) throws {
        didCallSetIsFromServerOnSoundId = true
    }

    // Author

    func insert(author newAuthor: MedoDelirio.Author) throws {
        didCallInsertAuthor = true
    }

    func update(author updatedAuthor: MedoDelirio.Author) throws {
        didCallUpdateAuthor = true
    }

    func delete(authorId: String) throws {
        didCallDeleteSound = true
    }

    // UserFolder

    func allFolders() throws -> [UserFolder] {
        folders
    }

    func contentsInside(userFolder userFolderId: String) throws -> [UserFolderContent] {
        contentInsideFolder.filter { $0.userFolderId == userFolderId }
    }

    func contentExistsInsideUserFolder(withId folderId: String, contentId: String) throws -> Bool {
        contentInsideFolder.contains(where: { $0.contentId == contentId })
    }

    func soundIdsInside(userFolder userFolderId: String) throws -> [String] {
        contentInsideFolder.compactMap {
            guard $0.userFolderId == userFolderId else { return nil }
            return $0.contentId
        }
    }

    func folderHashes() throws -> [String: String] {
        Dictionary(uniqueKeysWithValues: folders.map { ($0.id, $0.changeHash ?? "") })
    }

    func folders(withIds folderIds: [String]) throws -> [UserFolder] {
        folders.filter { folderIds.contains($0.id) }
    }

    // Song

    func insert(song newSong: Song) throws {
        didCallInsertSong = true
    }

    func update(song updatedSong: Song) throws {
        didCallUpdateSong = true
    }

    func delete(songId: String) throws {
        didCallDeleteSong = true
    }

    func setIsFromServer(to value: Bool, onSongId songId: String) throws {
        didCallSetIsFromServerOnSongId = true
    }

    // MusicGenre

    func insert(genre newGenre: MedoDelirio.MusicGenre) throws {
        didCallInsertGenre = true
    }

    func update(genre updatedGenre: MedoDelirio.MusicGenre) throws {
        didCallUpdateGenre = true
    }

    func delete(genreId: String) throws {
        didCallDeleteGenre = true
    }

    // UpdateEvent

    func insert(updateEvent newUpdateEvent: MedoDelirio.UpdateEvent) throws {
        didCallInsertUpdateEvent = true
        numberOfTimesInsertUpdateEventWasCalled += 1
        if let error = errorToThrowOnInsertUpdateEvent {
            throw error
        }
    }

    func markAsSucceeded(updateEventId: UUID) throws {
        didCallMarkAsSucceeded = true
    }

    func unsuccessfulUpdates() throws -> [MedoDelirio.UpdateEvent] {
        didCallUnsuccessfulUpdates = true
        guard let updates = unsuccessfulUpdatesToReturn else {
            return []
        }
        return updates
    }

    func exists(withId updateEventId: UUID) -> Bool {
        preexistingUpdates.contains(where: { $0.id == updateEventId })
    }

    func dateTimeOfLastUpdate() -> String {
        let dateFormatter = ISO8601DateFormatter()
        let dateArray = preexistingUpdates.compactMap { dateFormatter.date(from: $0.dateTime) }

        if let latestDate = dateArray.max() {
            return dateFormatter.string(from: latestDate)
        } else {
            return "all"
        }
    }

    // SyncLog

    func insert(syncLog newSyncLog: MedoDelirio.SyncLog) {
        didCallInsertSyncLog = true
    }

    // Retro 2023

    func getTopSoundsSharedByTheUser(_ limit: Int) throws -> [TopChartItem] {
        return topSharedSounds
    }

    func totalShareCount() -> Int {
        return shareCount
    }

    func allDatesInWhichTheUserShared() throws -> [Date] {
        return shareDates
    }

    func delete(reactionId: String) throws {
        didCallDeletePinnedReaction = true
    }

    func insert(_ pinnedReaction: Reaction) throws {}

    func pinnedReactions() throws -> [Reaction] {
        []
    }
}
