//
//  ViewStates.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 11/10/22.
//

import Foundation

enum JoinFolderResearchBannerViewState {

    case displayingRequestToJoin, sendingInfo, doneSending, errorSending
}

enum FolderResearchSettingsViewState {

    case enrolled, notEnrolled, sendingInfo, errorSending
}
