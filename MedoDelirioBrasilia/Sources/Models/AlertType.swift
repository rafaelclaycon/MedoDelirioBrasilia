//
//  AlertType.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import Foundation

enum AlertType {

    case singleOption, twoOptions, twoOptionsOneDelete, twoOptionsOneRedownload
}

enum AuthorDetailAlertType {

    case ok, reportSoundIssue, askForNewSound
}

enum FolderDetailAlertType {

    case ok, removeSingleSound, removeMultipleSounds
}
