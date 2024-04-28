//
//  AlertType.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import Foundation

@available(*, deprecated, message: "Use a more specific enum for each screen.")
enum AlertType {
    case singleOption, twoOptions, twoOptionsOneDelete, twoOptionsOneRedownload, twoOptionsOneContinue
}

enum SoundListAlertType {
    case soundFileNotFound, issueSharingSound, optionIncompatibleWithWhatsApp, issueExportingManySounds
}

enum AuthorDetailAlertType {
    case ok, reportSoundIssue, askForNewSound
}

enum FolderDetailAlertType {
    case ok, removeSingleSound, removeMultipleSounds
}
