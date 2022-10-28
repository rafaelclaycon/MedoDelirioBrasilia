//
//  ViewStates.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 11/10/22.
//

import Foundation

enum GenericViewState {

    case loading, displayingData, noDataToDisplay, loadingError

}

enum TrendsViewState {

    case loading, noDataToDisplay, displayingData

}

enum JoinFolderResearchBannerViewState {

    case displayingRequestToJoin, sendingInfo, doneSending, errorSending

}
