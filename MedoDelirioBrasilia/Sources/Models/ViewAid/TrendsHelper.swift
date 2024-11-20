//
//  TrendsHelper.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 14/12/22.
//

import Foundation

/// Class that allows the communication between `TrendsView` and `MainSoundContainer`.
///
/// - Parameters:
///    - soundIdToGoTo: Tells `MainSoundContainer` what soundId to scroll to.
///    - youCanScrollNow: After making sure it is in the `.allSounds` mode, scrolls to the correct sound.
class TrendsHelper: ObservableObject {

    @Published var soundIdToGoTo: String = ""
    @Published var timeIntervalToGoTo: TrendsTimeInterval? = nil
    @Published var refreshMostSharedByAudienceList: Bool = false
    @Published var youCanScrollNow: String = ""
}
