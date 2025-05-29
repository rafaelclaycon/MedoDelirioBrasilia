//
//  ContentUpdateServiceTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 03/05/23.
//

import Testing
@testable import MedoDelirio

@MainActor
struct ContentUpdateServiceTests {

    private var service: ContentUpdateService!

    private var apiClient: FakeAPIClient!
    private var localDatabase: FakeLocalDatabase!
    private var fileManager: FakeContentFileManager!
    private var appMemory: FakeAppPersistentMemory!
    private var logger: FakeLoggerService!
    private var delegate: FakeContentUpdateServiceDelegate!

    init() {
        self.apiClient = FakeAPIClient()
        self.localDatabase = FakeLocalDatabase()
        self.fileManager = FakeContentFileManager()
        self.appMemory = FakeAppPersistentMemory()
        self.logger = FakeLoggerService()
        self.delegate = FakeContentUpdateServiceDelegate()

        self.service = ContentUpdateService(
            apiClient: apiClient,
            database: localDatabase,
            fileManager: fileManager,
            appMemory: appMemory,
            logger: logger
        )
        self.service.delegate = delegate
    }

    @Test
    func update_whenNotAllowedYet_shouldReturnPendingStatus() async throws {
        await service.update()

        #expect(delegate.statusUpdates.count == 1)
        #expect(delegate.statusUpdates.first?.0 == ContentUpdateStatus.pendingFirstUpdate)
    }

    @Test
    func update_whenTryingToInsertContentThatAlreadyExists_shouldMarkThatSavedEventAsSucceeded() async throws {
        appMemory.hasAllowedContentUpdate(true)

        let event = UpdateEvent(contentId: "ABC", mediaType: .sound, eventType: .created, didSucceed: false)
        let sound = Sound(id: "ABC", title: "")

        localDatabase.localUpdates = [event]
        apiClient.updateEvents.append(event)
        apiClient.sound = sound
        localDatabase.sounds.append(sound)

        await service.update()

        #expect(delegate.statusUpdates.count == 2)
        #expect(delegate.statusUpdates[0].0 == ContentUpdateStatus.updating)
        #expect(delegate.statusUpdates[1].0 == ContentUpdateStatus.done)

        #expect(try localDatabase.unsuccessfulUpdates().isEmpty)
        #expect(!fileManager.didCallDownloadSound)
    }

    @Test
    func update_whenNewContent_shouldCreateDownloadAndMarkEventAsSucceeded() async throws {
        appMemory.hasAllowedContentUpdate(true)

        let event = UpdateEvent(contentId: "ABC", mediaType: .sound, eventType: .created, didSucceed: false)
        let sound = Sound(id: "ABC", title: "")

        apiClient.updateEvents.append(event)
        apiClient.sound = sound

        await service.update()

        #expect(delegate.statusUpdates.count == 2)
        #expect(delegate.statusUpdates[0].0 == ContentUpdateStatus.updating)
        #expect(delegate.statusUpdates[1].0 == ContentUpdateStatus.done)

        #expect(localDatabase.didCallInsertSound)
        #expect(fileManager.didCallDownloadSound)
        #expect(try localDatabase.unsuccessfulUpdates().isEmpty)
    }

    @Test
    func update_whenSoundMetadataUpdated_shouldUpdateSoundAndMarkEventAsSucceeded() async throws {
        appMemory.hasAllowedContentUpdate(true)

        let event = UpdateEvent(contentId: "ABC", mediaType: .sound, eventType: .metadataUpdated, didSucceed: false)
        let sound = Sound(id: "ABC", title: "")

        apiClient.updateEvents.append(event)
        apiClient.sound = sound

        await service.update()

        #expect(delegate.statusUpdates.count == 2)
        #expect(delegate.statusUpdates[0].0 == ContentUpdateStatus.updating)
        #expect(delegate.statusUpdates[1].0 == ContentUpdateStatus.done)

        #expect(!localDatabase.didCallInsertSound)
        #expect(localDatabase.didCallUpdateSound)
        #expect(!localDatabase.didCallDeleteSound)
        #expect(!fileManager.didCallDownloadSound)
        #expect(try localDatabase.unsuccessfulUpdates().isEmpty)
    }

    @Test
    func update_whenSoundFileUpdated_shouldRedownloadAndMarkEventAsSucceeded() async throws {
        appMemory.hasAllowedContentUpdate(true)

        let event = UpdateEvent(contentId: "ABC", mediaType: .sound, eventType: .fileUpdated, didSucceed: false)
        let sound = Sound(id: "ABC", title: "")

        apiClient.updateEvents.append(event)
        apiClient.sound = sound

        await service.update()

        #expect(delegate.statusUpdates.count == 2)
        #expect(delegate.statusUpdates[0].0 == ContentUpdateStatus.updating)
        #expect(delegate.statusUpdates[1].0 == ContentUpdateStatus.done)

        #expect(!localDatabase.didCallInsertSound)
        #expect(fileManager.didCallDownloadSound)
        #expect(try localDatabase.unsuccessfulUpdates().isEmpty)
    }

    @Test
    func update_whenSoundRemoved_shouldDeleteSoundDeleteFileAndMarkEventAsSucceeded() async throws {
        appMemory.hasAllowedContentUpdate(true)

        let event = UpdateEvent(contentId: "ABC", mediaType: .sound, eventType: .deleted, didSucceed: false)
        apiClient.updateEvents.append(event)

        await service.update()

        #expect(delegate.statusUpdates.count == 2)
        #expect(delegate.statusUpdates[0].0 == ContentUpdateStatus.updating)
        #expect(delegate.statusUpdates[1].0 == ContentUpdateStatus.done)

        #expect(localDatabase.didCallDeleteSound)
        #expect(fileManager.didCallRemoveSoundFile)
        #expect(try localDatabase.unsuccessfulUpdates().isEmpty)
    }

    @Test
    func update_whenAuthorEventErroneouslySetAsFileUpdated_shouldNotProcessItAtAll() async throws {
        appMemory.hasAllowedContentUpdate(true)

        let event = UpdateEvent(contentId: "ABC", mediaType: .author, eventType: .fileUpdated, didSucceed: false)
        apiClient.updateEvents.append(event)

        await service.update()

        #expect(delegate.statusUpdates.count == 2)
        #expect(delegate.statusUpdates[0].0 == ContentUpdateStatus.updating)
        #expect(delegate.statusUpdates[1].0 == ContentUpdateStatus.done)

        #expect(!localDatabase.didCallUpdateAuthor)
        #expect(!fileManager.didCallDownloadSound)
        #expect(!fileManager.didCallDownloadSong)
        #expect(try localDatabase.unsuccessfulUpdates().isEmpty)
    }
}
