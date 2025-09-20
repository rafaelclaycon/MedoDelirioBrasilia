//
//  FakeLocalDatabase.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Claycon Schmitt on 02/02/23.
//

import Foundation

enum CustomSQLiteError: Error {

    case databaseError(message: String)
    case queryError(message: String)
}

class FakeLocalDatabase: LocalDatabaseProtocol {

    var folders = [UserFolder]()
    var contentInsideFolder = [UserFolderContent]()
    var localUpdates = [UpdateEvent]()
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

    var sounds = [Sound]()

    var didCallDeletePinnedReaction = false

    // Content

    func content(withIds contentIds: [String]) throws -> [AnyEquatableMedoContent] {
        []
    }

    // Favorite

    func isFavorite(contentId: String) throws -> Bool {
        false
    }

    func insert(favorite newFavorite: Favorite) throws {
        //
    }

    func favorites() throws -> [Favorite] {
        []
    }

    func deleteFavorite(withId contentId: String) throws {
        //
    }

    // Sound

    func insert(sound newSound: Sound) throws {
        didCallInsertSound = true
        if sounds.contains(where: { $0.id == newSound.id }) {
            throw CustomSQLiteError.databaseError(message: "A operação não pôde ser concluída. (SQLite.Result erro 0.)")
        }
    }

    func update(sound updatedSound: Sound) throws {
        didCallUpdateSound = true
    }

    func delete(soundId: String) throws {
        didCallDeleteSound = true
    }

    func setIsFromServer(to value: Bool, onSoundId soundId: String) throws {
        didCallSetIsFromServerOnSoundId = true
    }

    func sounds(withIds soundIds: [String]) throws -> [Sound] {
        []
    }

    func sounds(allowSensitive: Bool) throws -> [Sound] {
        []
    }

    func contentExists(withId contentId: String) throws -> Bool {
        sounds.contains(where: { $0.id == contentId })
    }

    // Author

    func allAuthors() throws -> [Author] {
        []
    }

    func insert(author newAuthor: Author) throws {
        didCallInsertAuthor = true
    }

    func update(author updatedAuthor: Author) throws {
        didCallUpdateAuthor = true
    }

    func delete(authorId: String) throws {
        didCallDeleteSound = true
    }

    func author(withId authorId: String) throws -> Author? {
        nil
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

    func insert(contentId: String, intoUserFolder userFolderId: String) throws {
        //
    }

    func contentIdsInside(userFolder userFolderId: String) throws -> [String] {
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

    func update(userSortPreference: Int, forFolderId userFolderId: String) throws {
        //
    }

    func insert(_ userFolder: UserFolder) throws {
        //
    }

    func update(_ userFolder: UserFolder) throws {
        //
    }

    func deleteUserFolder(withId folderId: String) throws {
        //
    }

    func deleteUserContentFromFolder(withId folderId: String, contentId: String) throws {
        //
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

    func songs(withIds songIds: [String]) throws -> [Song] {
        []
    }

    func songs(allowSensitive: Bool) throws -> [Song] {
        []
    }

    // MusicGenre

    func insert(genre newGenre: MusicGenre) throws {
        didCallInsertGenre = true
    }

    func update(genre updatedGenre: MusicGenre) throws {
        didCallUpdateGenre = true
    }

    func delete(genreId: String) throws {
        didCallDeleteGenre = true
    }

    func musicGenre(withId genreId: String) throws -> MusicGenre? {
        nil
    }

    // UpdateEvent

    func insert(updateEvent newUpdateEvent: UpdateEvent) throws {
        didCallInsertUpdateEvent = true
        numberOfTimesInsertUpdateEventWasCalled += 1
        if let error = errorToThrowOnInsertUpdateEvent {
            throw error
        }
    }

    func markAsSucceeded(updateEventId: UUID) throws {
        didCallMarkAsSucceeded = true
        for i in stride(from: 0, to: localUpdates.count, by: 1) {
            if localUpdates[i].id == updateEventId {
                localUpdates[i].didSucceed = true
            }
        }
    }

    func unsuccessfulUpdates() throws -> [UpdateEvent] {
        didCallUnsuccessfulUpdates = true
        return localUpdates.filter { $0.didSucceed == false }
    }

    func exists(withId updateEventId: UUID) -> Bool {
        return localUpdates.contains(where: { $0.id == updateEventId })
    }

    func dateTimeOfLastUpdate() -> String {
        let dateFormatter = ISO8601DateFormatter()
        let dateArray = localUpdates.compactMap { dateFormatter.date(from: $0.dateTime) }

        if let latestDate = dateArray.max() {
            return dateFormatter.string(from: latestDate)
        } else {
            return "all"
        }
    }

    // SyncLog

    func insert(syncLog newSyncLog: SyncLog) {
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

    // Pinned Reactions

    func insert(_ pinnedReaction: Reaction) throws {}

    func pinnedReactions() throws -> [Reaction] {
        []
    }

    func delete(reactionId: String) throws {
        didCallDeletePinnedReaction = true
    }

    func markAllUserShareLogsAsSentToServer() throws {
        //
    }

    func clearAudienceSharingStatisticTable() throws {
        //
    }
}
