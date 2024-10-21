//
//  ModalViewToOpen.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 22/04/24.
//

import Foundation

enum MainViewModalToOpen {

    case settings
    case onboarding
    case whatsNew
    case retrospective
}

enum MainSoundContainerModalToOpen {

    case syncInfo
}

enum SoundListModalToOpen {

    case shareAsVideo
    case addToFolder
    case soundDetail
    case soundIssueEmailPicker
    case authorIssueEmailPicker(Sound)
}
