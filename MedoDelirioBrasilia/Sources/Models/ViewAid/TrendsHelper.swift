//
//  TrendsHelper.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 14/12/22.
//

import SwiftUI

/// Class that allows the communication between `TrendsView` and other tabs.
///
/// - Parameters:
///    - notifyMainSoundContainer: Tells `MainSoundContainerView` what soundId to scroll to.
///    - soundIdToGoTo: After making sure it is in the `.all` mode, scrolls to the correct sound.
@Observable class TrendsHelper {

    // To Sounds tab
    var contentIdToNavigateTo: String = ""

    // To Songs tab
    var songIdToNavigateTo: String = ""

    // To Reactions tab
    var reactionIdToNavigateTo: String = ""

    // From Siri Suggestions
    var timeIntervalToGoTo: TrendsTimeInterval? = nil
    var refreshMostSharedByAudienceList: Bool = false
}
