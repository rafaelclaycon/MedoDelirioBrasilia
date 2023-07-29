//
//  MainViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 08/07/23.
//

import Combine
import Foundation

@MainActor
class MainViewViewModel: ObservableObject {

    @Published var showSyncProgressView = false
    @Published var message = "Procurando atualizações..."
    @Published var currentAmount: Double = 0
    @Published var totalAmount: Double = 1
    @Published var localUnsuccessfulUpdates: [UpdateEvent]? = nil
    @Published var serverUpdates: [UpdateEvent]? = nil
    @Published var updateSoundList: Bool = false
    @Published var showYoureOfflineWarning = false
    @Published var lastUpdateDate: String

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
            return showYoureOfflineWarning = true
        }

        await MainActor.run {
            showSyncProgressView = true
        }

//        if #available(iOS 16, *) {
//            do {
//                try await Task.sleep(for: .seconds(15))
//            } catch {
//                print(error)
//            }
//        }

        do {
            try await retryLocal()
            try await syncDataWithServer()
            updateSoundList = true
            showSyncProgressView = false
        } catch SyncError.noInternet {
            updateSoundList = true
            showSyncProgressView = false
        } catch NetworkRabbitError.errorFetchingUpdateEvents(let errorMessage) {
            print(errorMessage)
            logger.logSyncError(description: errorMessage, updateEventId: "")
            updateSoundList = true
            showSyncProgressView = false
        } catch {
            print(error)
        }
    }

    func retryLocal() async throws {
        let localResult = try await retrieveUnsuccessfulLocalUpdates()
        print("Resultado do fetchLocalUnsuccessfulUpdates: \(localResult)")
        if localResult > 0 {
            await MainActor.run {
                totalAmount = localResult
            }
            try await syncUnsuccessful()
        }
    }

    func syncDataWithServer() async throws {
        let result = try await retrieveServerUpdates()
        print("Resultado do retrieveServerUpdates: \(result)")
        if result > 0 {
            await MainActor.run {
                totalAmount = result
            }
            try await serverSync()
        }
    }

    func retrieveServerUpdates() async throws -> Double {
        print("fetchServerUpdates()")
        serverUpdates = try await service.getUpdates(from: lastUpdateDate)
        if var serverUpdates = serverUpdates {
            for i in serverUpdates.indices {
                serverUpdates[i].didSucceed = false
                try database.insert(updateEvent: serverUpdates[i])
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
            sleep(1)
            await MainActor.run {
                currentAmount += 1.0
            }
        }

        lastUpdateDate = Date.now.iso8601withFractionalSeconds
        //print(Date.now.iso8601withFractionalSeconds)
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

        currentAmount = 0.0
        for update in localUnsuccessfulUpdates {
            await service.process(updateEvent: update)
            sleep(1)
            await MainActor.run {
                currentAmount += 1.0
            }
        }
    }
}
