//
//  SyncManager.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 22/09/23.
//

import SwiftUI

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
        guard service.hasConnectivity() else {
            delegate?.didFinishUpdating(status: .noInternet, updateSoundList: false)
            return
        }

        await MainActor.run {
            delegate?.didFinishUpdating(status: .updating, updateSoundList: false)
        }

        do {
            try await retryLocal()
            try await syncDataWithServer()
            delegate?.didFinishUpdating(status: .done, updateSoundList: true)
        } catch SyncError.noInternet {
            delegate?.didFinishUpdating(status: .noInternet, updateSoundList: false)
        } catch NetworkRabbitError.errorFetchingUpdateEvents(let errorMessage) {
            print(errorMessage)
            logger.logSyncError(description: errorMessage, updateEventId: "")
            delegate?.didFinishUpdating(status: .updateError, updateSoundList: false)
        } catch SyncError.errorInsertingUpdateEvent(let updateEventId) {
            logger.logSyncError(description: "Erro ao tentar inserir UpdateEvent no banco de dados.", updateEventId: updateEventId)
            delegate?.didFinishUpdating(status: .updateError, updateSoundList: false)
        } catch {
            logger.logSyncError(description: error.localizedDescription, updateEventId: "")
            delegate?.didFinishUpdating(status: .updateError, updateSoundList: false)
        }

        AppPersistentMemory.setLastUpdateAttempt(to: Date.now.iso8601withFractionalSeconds)
    }

    func retryLocal() async throws {
        let localResult = try await retrieveUnsuccessfulLocalUpdates()
        print("Resultado do fetchLocalUnsuccessfulUpdates: \(localResult)")
        if localResult > 0 {
            try await syncUnsuccessful()
        }
    }

    func syncDataWithServer() async throws {
        let result = try await retrieveServerUpdates()
        print("Resultado do retrieveServerUpdates: \(result)")
        if result > 0 {
            try await serverSync()
        } else {
            logger.logSyncSuccess(description: "Sincronização realizada com sucesso, porém não existem novas atualizações.", updateEventId: "")
        }
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
            guard service.hasConnectivity() else {
                throw SyncError.noInternet
            }

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
        guard service.hasConnectivity() else {
            throw SyncError.noInternet
        }

        for update in localUnsuccessfulUpdates {
            await service.process(updateEvent: update)
        }
    }
}
