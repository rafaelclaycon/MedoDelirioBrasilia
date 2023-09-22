//
//  SyncManager.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 22/09/23.
//

import SwiftUI

protocol SyncManagerDelegate: AnyObject {
    func syncManagerDidUpdate(status: SyncUIStatus)
}

class SyncManager {

    weak var delegate: SyncManagerDelegate?

    private var localUnsuccessfulUpdates: [UpdateEvent]? = nil
    private var serverUpdates: [UpdateEvent]? = nil

    private var lastUpdateDate: String

    @AppStorage("lastUpdateDate") private var lastUpdateDateInUserDefaults = "all"
    @AppStorage("lastUpdateAttempt") private var lastUpdateAttemptInUserDefaults = ""

    private var service: SyncServiceProtocol
    private var database: LocalDatabaseProtocol
    private var logger: LoggerProtocol

    init(
        lastUpdateDate: String,
        service: SyncServiceProtocol,
        database: LocalDatabaseProtocol,
        logger: LoggerProtocol
    ) {
        self.lastUpdateDate = lastUpdateDate
        self.service = service
        self.database = database
        self.logger = logger
    }

    func sync() async {
        guard service.hasConnectivity() else {
            delegate?.syncManagerDidUpdate(status: .noInternet)
            return
        }

        await MainActor.run {
            delegate?.syncManagerDidUpdate(status: .updating)
        }

        do {
            try await retryLocal()
            try await syncDataWithServer()
            delegate?.syncManagerDidUpdate(status: .done)
            // updateSoundList = true
        } catch SyncError.noInternet {
            delegate?.syncManagerDidUpdate(status: .noInternet)
        } catch NetworkRabbitError.errorFetchingUpdateEvents(let errorMessage) {
            print(errorMessage)
            logger.logSyncError(description: errorMessage, updateEventId: "")
            delegate?.syncManagerDidUpdate(status: .updateError)
        } catch SyncError.errorInsertingUpdateEvent(let updateEventId) {
            logger.logSyncError(description: "Erro ao tentar inserir UpdateEvent no banco de dados.", updateEventId: updateEventId)
            delegate?.syncManagerDidUpdate(status: .updateError)
        } catch {
            logger.logSyncError(description: error.localizedDescription, updateEventId: "")
            delegate?.syncManagerDidUpdate(status: .updateError)
        }

        lastUpdateAttemptInUserDefaults = Date.now.iso8601withFractionalSeconds
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
        print("lastUpdateDate: \(lastUpdateDate)")
        serverUpdates = try await service.getUpdates(from: lastUpdateDate)
        if var serverUpdates = serverUpdates {
            for i in serverUpdates.indices {
                serverUpdates[i].didSucceed = false
                do {
                    try database.insert(updateEvent: serverUpdates[i])
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

        for update in serverUpdates {
            guard service.hasConnectivity() else {
                throw SyncError.noInternet
            }

            await service.process(updateEvent: update)
        }

        lastUpdateDateInUserDefaults = Date.now.iso8601withFractionalSeconds
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
