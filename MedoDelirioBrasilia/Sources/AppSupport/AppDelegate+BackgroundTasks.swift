//
//  AppDelegate+BackgroundTasks.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 05/12/24.
//

import Foundation
import BackgroundTasks
import ActivityKit
import MedoDelirioSyncWidgetExtension

extension AppDelegate {

    func taskId() -> String {
        "com.rafaelschmitt.MedoDelirioBrasilia.syncTask"
    }

    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskId(),
            using: nil
        ) { task in
            Task {
                await self.handleSyncTask(task: task as! BGAppRefreshTask)
            }
        }
    }

    func scheduleBackgroundSync() {
        let request = BGAppRefreshTaskRequest(identifier: taskId())
        request.earliestBeginDate = .now

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule background sync: \(error)")
        }
    }

    func handleSyncTask(task: BGAppRefreshTask) async {
        scheduleBackgroundSync() // Schedule the next task

        task.expirationHandler = {
            print("Background task expired")
        }

        do {
            // Perform your sync logic asynchronously
            try await performSyncLogic()
            task.setTaskCompleted(success: true)
        } catch NetworkRabbitError.errorFetchingUpdateEvents(let errorMessage) {
            print("Error performing sync logic - fetch error: \(errorMessage)")
            print(errorMessage)
            Logger.shared.logSyncError(description: errorMessage)
            //delegate?.didFinishUpdating(status: .updateError, updateSoundList: false)
        } catch SyncError.errorInsertingUpdateEvent(let updateEventId) {
            print("Error performing sync logic - insert update error: \(updateEventId)")
            Logger.shared.logSyncError(description: "Erro ao tentar inserir UpdateEvent no banco de dados.", updateEventId: updateEventId)
            //delegate?.didFinishUpdating(status: .updateError, updateSoundList: false)
        } catch {
            print("Error performing sync logic: \(error)")
            Logger.shared.logSyncError(description: error.localizedDescription)
            //delegate?.didFinishUpdating(status: .updateError, updateSoundList: false)
            task.setTaskCompleted(success: false)
        }
    }

    func performSyncLogic() async throws {
        print("Performing background sync logic")

        let syncManager = SyncManager(
            service: SyncService(
                networkRabbit: NetworkRabbit.shared,
                localDatabase: LocalDatabase.shared
            ),
            database: LocalDatabase.shared,
            logger: Logger.shared
        )



        try await syncManager.sync()
    }
}

// MARK: - Live Activity

extension AppDelegate {

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
}
