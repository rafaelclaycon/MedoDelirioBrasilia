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

    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskId,
            using: nil
        ) { task in
            Task {
                await self.handleSyncTask(task: task as! BGAppRefreshTask)
            }
        }
    }

    func scheduleBackgroundSync() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskId)
        request.earliestBeginDate = .now

        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background sync task scheduled")
        } catch {
            print("Failed to schedule background sync: \(error)")
        }
    }

    func handleSyncTask(task: BGAppRefreshTask) async {
        currentTask = task

        scheduleBackgroundSync() // Schedule the next task

        task.expirationHandler = {
            self.syncManager?.cancelSync()
            print("Background task expired")
        }

        await performSyncLogic()
    }

    func performSyncLogic() async {
        print("Performing background sync logic")

        self.syncManager = SyncManager(
            service: SyncService(
                networkRabbit: NetworkRabbit.shared,
                localDatabase: LocalDatabase.shared
            ),
            database: LocalDatabase.shared,
            logger: Logger.shared
        )

        syncManager?.delegate = self

        await syncManager?.sync()
    }
}

// MARK: - Live Activity

extension AppDelegate: SyncManagerDelegate {

    func set(totalUpdateCount: Int) {
        print("LIVE ACTIVITY: Set total updates")
        self.totalUpdateCount = totalUpdateCount
        startActivity(current: 0, total: totalUpdateCount)
    }
    
    func didProcessUpdate(number: Int) async {
        print("LIVE ACTIVITY: Did process, #\(number)")

        guard let activity else {
            return
        }

        let contentState = SyncActivityAttributes.ContentState(
            status: "updating", current: number, total: self.totalUpdateCount
        )

        await activity.update(
            ActivityContent<SyncActivityAttributes.ContentState>(
                state: contentState,
                staleDate: Date.now + 15,
                relevanceScore: 50
            )
        )
    }
    
    func didFinishUpdating(status: SyncUIStatus, updateSoundList: Bool) async {
        guard status != .updating else { return }
        guard let activity else { return }

        var finalContent: SyncActivityAttributes.ContentState
        if status == .done {
            finalContent = SyncActivityAttributes.ContentState(
                status: "done", current: self.totalUpdateCount, total: self.totalUpdateCount
            )
        } else {
            finalContent = SyncActivityAttributes.ContentState(
                status: "updateError", current: 0, total: 0
            )
        }

        await activity.end(
            ActivityContent(state: finalContent, staleDate: nil)
        )

        currentTask?.setTaskCompleted(success: true)
        currentTask = nil
    }

    func startActivity(current: Int, total: Int) {
        let attributes = SyncActivityAttributes(title: "Sync")
        let initialState = SyncActivityAttributes.ContentState(status: "updating", current: current, total: total)

        let oneHourAhead = Calendar.current.date(byAdding: .hour, value: 1, to: .now)

        do {
            self.activity = try Activity<SyncActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: oneHourAhead),
                pushType: .token
            )
            print("Activity started: \(self.activity?.id ?? "")")
        } catch {
            print("Failed to start activity: \(error)")
        }
    }
}
