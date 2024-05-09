//
//  DynamicBanner.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 09/05/24.
//

import Foundation

struct DynamicBanner {

    let symbol: String
    let title: String
    let text: String
    let buttons: [DynamicBannerButton]
}

struct DynamicBannerButton {

    let title: String
    let type: DynamicBannerButtonType
    let data: String
}

enum DynamicBannerButtonType: String {

    case copyText, openLink
}
