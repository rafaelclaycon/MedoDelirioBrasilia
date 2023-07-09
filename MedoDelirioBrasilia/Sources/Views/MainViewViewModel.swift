//
//  MainViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 08/07/23.
//

import Combine
import Foundation

class MainViewViewModel: ObservableObject {

    @Published var showSyncProgressView = false
    @Published var message = "Verificando atualizações..."
    @Published var currentAmount = 0.0
    @Published var totalAmount = 1.0
    @Published var localUnsuccessfulUpdates: [UpdateEvent]? = nil
    @Published var serverUpdates: [UpdateEvent]? = nil
    @Published var updateSoundList: Bool = false
    @Published var showYoureOfflineWarning = false
    @Published var lastUpdateDate: String

    private var service: SyncServiceProtocol

    init(lastUpdateDate: String, service: SyncServiceProtocol) {
        self.lastUpdateDate = lastUpdateDate
        self.service = service
    }

    func sync() async {
        guard service.hasConnectivity() else {
            return showYoureOfflineWarning = true
        }

        do {
            try await retryLocal()
            try await syncDataWithServer()
            updateSoundList = true
            showSyncProgressView = false
        } catch {
            print(error)
        }
    }

    func retryLocal() async throws {
        let localResult = try await fetchLocalUnsuccessfulUpdates()
        print("Resultado do fetchLocalUnsuccessfulUpdates: \(localResult)")
        if localResult > 0 {
            await MainActor.run {
                showSyncProgressView = true
                totalAmount = localResult
            }
            try await syncUnsuccessful()
        }
    }

    func syncDataWithServer() async throws {
        let result = try await fetchServerUpdates()
        print("Resultado do fetchServerUpdates: \(result)")
        if result > 0 {
            await MainActor.run {
                showSyncProgressView = true
                totalAmount = result
            }
            try await serverSync()
        }
    }

    func fetchServerUpdates() async throws -> Double {
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

    func fetchLocalUnsuccessfulUpdates() async throws -> Double {
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
        guard service.hasConnectivity() else {
            throw SyncError.noInternet
        }

        currentAmount = 0.0
        for update in serverUpdates {
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
