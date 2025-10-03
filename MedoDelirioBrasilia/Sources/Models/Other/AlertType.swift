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

enum PlayableContentAlert {

    case contentFileNotFound
    case issueSharingContent
    case unableToRedownloadContent
}

enum ContentGridAlert {

    case issueExportingManySounds
    case removeSingleContent
    case removeMultipleContent
    case issueRemovingContentFromFolder
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
