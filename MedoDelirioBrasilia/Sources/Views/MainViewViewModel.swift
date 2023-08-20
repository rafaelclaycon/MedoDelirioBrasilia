//
//  MainViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 08/07/23.
//

import Combine
import SwiftUI

@MainActor
class MainViewViewModel: ObservableObject {
    @EnvironmentObject var syncValues: SyncValues

    private var localUnsuccessfulUpdates: [UpdateEvent]? = nil
    private var serverUpdates: [UpdateEvent]? = nil
    @Published var updateSoundList: Bool = false

    private var lastUpdateDate: String

    @AppStorage("lastUpdateDate") private var lastUpdateDateInUserDefaults = "all"

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
            syncValues.syncStatus = .noInternet
            return
        }

        await MainActor.run {
            syncValues.syncStatus = .updating
        }

        do {
            try await retryLocal()
            try await syncDataWithServer()
            updateSoundList = true
            syncValues.syncStatus = .done
        } catch SyncError.noInternet {
            syncValues.syncStatus = .noInternet
        } catch NetworkRabbitError.errorFetchingUpdateEvents(let errorMessage) {
            print(errorMessage)
            logger.logSyncError(description: errorMessage, updateEventId: "")
            syncValues.syncStatus = .done // Maybe .updateError down the line?
        } catch SyncError.errorInsertingUpdateEvent(let updateEventId) {
            logger.logSyncError(description: "Erro ao tentar inserir UpdateEvent no banco de dados.", updateEventId: updateEventId)
            syncValues.syncStatus = .done
        } catch {
            logger.logSyncError(description: error.localizedDescription, updateEventId: "")
            syncValues.syncStatus = .done
        }
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
        print("syncUnsucceeded()")
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
