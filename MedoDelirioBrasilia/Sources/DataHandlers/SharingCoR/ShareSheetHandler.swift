//
//  ShareSheetHandler.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 15/11/24.
//

import UIKit

class ShareSheetHandler: ShareHandler {

    var nextHandler: ShareHandler?

    func handle(sound: Sound, context: inout ShareContext) async throws {
        guard let fileURL = context.fileURL else { throw NSError(domain: "ShareSheet", code: 500, userInfo: nil) }

        await presentSheet(fileURL)

        try await nextHandler?.handle(sound: sound, context: &context)
    }

    private func presentSheet(_ fileURL: URL) async {
        let activityVC = await UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)

        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }

        let _: (completed: Bool, destination: ShareDestination?, activityRawValue: String?) = await withCheckedContinuation { continuation in
            activityVC.completionWithItemsHandler = { activity, completed, items, error in
                if completed, let activity {
                    let destination = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
                    continuation.resume(returning: (true, destination, activity.rawValue))
                } else {
                    continuation.resume(returning: (false, nil, nil))
                }
            }
        }
    }
}
