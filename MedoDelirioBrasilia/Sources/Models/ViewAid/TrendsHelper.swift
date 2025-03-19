//
//  TrendsHelper.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 14/12/22.
//

import SwiftUI

/// Class that allows the communication between `TrendsView` and `MainSoundContainer`.
///
/// - Parameters:
///    - soundIdToGoTo: Tells `MainSoundContainer` what soundId to scroll to.
///    - youCanScrollNow: After making sure it is in the `.allSounds` mode, scrolls to the correct sound.
@Observable class TrendsHelper {

    var soundIdToGoTo: String = ""
    var timeIntervalToGoTo: TrendsTimeInterval? = nil
    var refreshMostSharedByAudienceList: Bool = false
    var youCanScrollNow: String = ""
}
