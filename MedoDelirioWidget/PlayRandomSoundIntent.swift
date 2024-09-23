//
//  PlayRandomSoundIntent.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 22/09/24.
//

import AppIntents
import SwiftUI
import WidgetKit

struct PlayRandomSoundIntent: AppIntent {

    static let title: LocalizedStringResource = "Tocar som aleatório"

    func perform() async throws -> some IntentResult {
        //let player = AudioPlayer()
        return .result()
    }
}

@available(iOSApplicationExtension, unavailable)
extension PlayRandomSoundIntent: ForegroundContinuableIntent { }
