//
//  MedoDelirioSyncWidgetBundle.swift
//  MedoDelirioSyncWidget
//
//  Created by Rafael Schmitt on 02/12/24.
//

import WidgetKit
import SwiftUI

@main
struct MedoDelirioSyncWidgetBundle: WidgetBundle {
    var body: some Widget {
        MedoDelirioSyncWidget()
        MedoDelirioSyncWidgetLiveActivity()
    }
}
