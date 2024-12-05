//
//  SyncManager.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 22/09/23.
//

import SwiftUI
import ActivityKit
import MedoDelirioSyncWidgetExtension

protocol SyncManagerDelegate: AnyObject {
    func set(totalUpdateCount: Int)
    func didProcessUpdate(number: Int)
    func didFinishUpdating(status: SyncUIStatus, updateSoundList: Bool)
}

class SyncManager {

    weak var delegate: SyncManagerDelegate?

    private var localUnsuccessfulUpdates: [UpdateEvent]? = nil
    private var serverUpdates: [UpdateEvent]? = nil

    private var service: SyncServiceProtocol
    private var database: LocalDatabaseProtocol
    private var logger: LoggerProtocol

    init(
        service: SyncServiceProtocol,
        database: LocalDatabaseProtocol,
        logger: LoggerProtocol
    ) {
        self.service = service
        self.database = database
        self.logger = logger
    }

    func sync() async {
        await MainActor.run {
            delegate?.didFinishUpdating(status: .updating, updateSoundList: false)
        }

        do {
            startActivity()

            let didHaveAnyLocalUpdates = try await retryLocal()
            let didHaveAnyRemoteUpdates = try await syncDataWithServer()

            if didHaveAnyLocalUpdates || didHaveAnyRemoteUpdates {
                logger.logSyncSuccess(description: "Sincronização realizada com sucesso.")
            } else {
                logger.logSyncSuccess(description: "Sincronização realizada com sucesso, porém não existem novas atualizações.")
            }

            delegate?.didFinishUpdating(
                status: .done,
                updateSoundList: didHaveAnyLocalUpdates || didHaveAnyRemoteUpdates
            )
        } catch NetworkRabbitError.errorFetchingUpdateEvents(let errorMessage) {
            print(errorMessage)
            logger.logSyncError(description: errorMessage)
            delegate?.didFinishUpdating(status: .updateError, updateSoundList: false)
        } catch SyncError.errorInsertingUpdateEvent(let updateEventId) {
            logger.logSyncError(description: "Erro ao tentar inserir UpdateEvent no banco de dados.", updateEventId: updateEventId)
            delegate?.didFinishUpdating(status: .updateError, updateSoundList: false)
        } catch {
            logger.logSyncError(description: error.localizedDescription)
            delegate?.didFinishUpdating(status: .updateError, updateSoundList: false)
        }

        AppPersistentMemory().setLastUpdateAttempt(to: Date.now.iso8601withFractionalSeconds)

        await syncFolderResearchChangesUp()
    }

    func startActivity() {
        let atttributes = SyncActivityAttributes(title: "Sync")
        let initialState = SyncActivityAttributes.ContentState(status: "updating", current: 3, total: 10)

        do {
            let activity = try Activity<SyncActivityAttributes>.request(
                attributes: atttributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: .token
            )
            print("Activity started: \(activity.id)")
        } catch {
            print("Failed to start activity: \(error)")
        }
    }

    func retryLocal() async throws -> Bool {
        let localResult = try await retrieveUnsuccessfulLocalUpdates()
        print("Resultado do fetchLocalUnsuccessfulUpdates: \(localResult)")
        if localResult > 0 {
            try await syncUnsuccessful()
        }
        return localResult > 0
    }

    func syncDataWithServer() async throws -> Bool {
        let result = try await retrieveServerUpdates()
        print("Resultado do retrieveServerUpdates: \(result)")
        if result > 0 {
            try await serverSync()
        }
        return result > 0
    }

    func retrieveServerUpdates() async throws -> Double {
        print("retrieveServerUpdates()")
        let lastUpdateDate = database.dateTimeOfLastUpdate()
        print("lastUpdateDate: \(lastUpdateDate)")
        serverUpdates = try await service.getUpdates(from: lastUpdateDate)
        if var serverUpdates = serverUpdates {
            for i in serverUpdates.indices {
                do {
                    if try !database.exists(withId: serverUpdates[i].id) {
                        serverUpdates[i].didSucceed = false
                        try database.insert(updateEvent: serverUpdates[i])
                    }
                } catch {
                    throw SyncError.errorInsertingUpdateEvent(updateEventId: serverUpdates[i].id.uuidString)
                }
            }
        }
        return Double(serverUpdates?.count ?? 0)
    }

    func retrieveUnsuccessfulLocalUpdates() async throws -> Double {
        print("fetchLocalUnsuccessfulUpdates()")
        localUnsuccessfulUpdates = try database.unsuccessfulUpdates()
        return Double(localUnsuccessfulUpdates?.count ?? 0)
    }

    func serverSync() async throws {
        print("serverSync()")
        guard let serverUpdates = serverUpdates else { return }
        guard serverUpdates.isEmpty == false else {
            return print("NO UPDATES")
        }

        var updateNumber: Int = 0
        delegate?.set(totalUpdateCount: serverUpdates.count)

        for update in serverUpdates {
            await service.process(updateEvent: update)

            updateNumber += 1
            delegate?.didProcessUpdate(number: updateNumber)
        }
    }

    func syncUnsuccessful() async throws {
        print("syncUnsuccessful()")
        guard let localUnsuccessfulUpdates = localUnsuccessfulUpdates else { return }
        guard localUnsuccessfulUpdates.isEmpty == false else {
            return print("NO LOCAL UNSUCCESSFUL UPDATES")
        }

        for update in localUnsuccessfulUpdates {
            await service.process(updateEvent: update)
        }
    }

    private func syncFolderResearchChangesUp() async {
        do {
            let provider = FolderResearchProvider(
                userSettings: UserSettings(),
                appMemory: AppPersistentMemory(),
                localDatabase: LocalDatabase(),
                repository: FolderResearchRepository()
            )
            try await provider.sendChanges()
        } catch {
            Analytics().send(
                originatingScreen: "SyncManager",
                action: "issueSyncingFolderResearchChanges(\(error.localizedDescription))"
            )
        }
    }
}
