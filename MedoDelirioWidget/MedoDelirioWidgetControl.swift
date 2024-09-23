//
//  MedoDelirioWidgetControl.swift
//  MedoDelirioWidget
//
//  Created by Rafael Schmitt on 22/09/24.
//

import AppIntents
import SwiftUI
import WidgetKit

struct MedoDelirioWidgetControl: ControlWidget {

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.rafaelschmitt.MedoDelirioBrasilia.MedoDelirioWidget"
        ) {
            ControlWidgetButton(
                "Tocar Som Aleatório",
                action: PlayRandomSoundIntent()
            ) { isActive in
                Image(systemName: "shuffle")
                if isActive {
                    Text("Executando...")
                }
            }
        }
        .displayName("Tocar Som")
        .description("Um controle que abre o app e toca um som aleatório.")
    }
}
