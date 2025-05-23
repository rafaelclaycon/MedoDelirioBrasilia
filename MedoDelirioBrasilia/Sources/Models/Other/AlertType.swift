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

    case soundFileNotFound
    case issueSharingSound
    case issueExportingManySounds
    case removeSingleSound
    case removeMultipleSounds
    case unableToRedownloadSound
    case issueRemovingSoundFromFolder
}

enum AuthorDetailAlertType {

    case ok, reportSoundIssue, askForNewSound
}

enum FolderDetailAlertType {

    case ok, removeSingleSound, removeMultipleSounds
}

enum SongsViewAlert {

    case ok, songUnavailable, redownloadSong
}

enum AddToFolderAlertType {

    case ok, addOnlyNonOverlapping
}
