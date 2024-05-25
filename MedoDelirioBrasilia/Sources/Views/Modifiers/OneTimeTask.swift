//
//  OneTimeTask.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 21/09/23.
//

import SwiftUI

private struct OneTimeTask: ViewModifier {

    @State private var didRun = false
    let priority: TaskPriority
    let action: () async -> Void

    func body(content: Content) -> some View {
        content
            .task(priority: priority) {
                guard !didRun else { return }
                didRun = true
                await action()
            }
    }
}

extension View {

    func oneTimeTask(
        priority: TaskPriority = .userInitiated,
        @_inheritActorContext action: @Sendable @escaping () async -> Void
    ) -> some View {
        modifier(OneTimeTask(priority: priority, action: action))
    }
}
