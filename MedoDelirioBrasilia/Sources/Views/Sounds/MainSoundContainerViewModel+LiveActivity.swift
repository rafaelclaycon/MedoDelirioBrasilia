//
//  MainSoundContainerViewModel+LiveActivity.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 09/12/24.
//

import Foundation
import ActivityKit
import MedoDelirioSyncWidgetExtension

extension MainSoundContainerViewModel {

    func startLiveActivity(current: Int, total: Int) {
        let attributes = SyncActivityAttributes(title: "Sync")
        let initialState = SyncActivityAttributes.ContentState(status: "updating", current: current, total: total)

        let oneHourAhead = Calendar.current.date(byAdding: .hour, value: 1, to: .now)

        do {
            self.activity = try Activity<SyncActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: oneHourAhead),
                pushType: .token
            )
            print("LIVE ACTIVITY started: \(self.activity?.id ?? "")")
        } catch {
            print("Failed to start LIVE ACTIVITY: \(error)")
        }
    }

    func updateLiveActivity(current: Int) async {
        guard let activity else {
            return
        }

        print("LIVE ACTIVITY: Will process #\(current)")

        let contentState = SyncActivityAttributes.ContentState(
            status: "updating", current: current, total: self.totalUpdateCount
        )

        await activity.update(
            ActivityContent<SyncActivityAttributes.ContentState>(
                state: contentState,
                staleDate: Date.now + 15,
                relevanceScore: 50
            )
        )
    }

    func endLiveActivity(status: SyncUIStatus) async {
        guard let activity else { return }

        print("LIVE ACTIVITY: Will end")

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
    }
}
