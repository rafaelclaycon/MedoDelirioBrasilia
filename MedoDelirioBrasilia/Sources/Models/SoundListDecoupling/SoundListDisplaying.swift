//
//  SoundListDisplaying.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 16/04/24.
//

import SwiftUI

protocol SoundListDisplaying {

    func displayToast(
        _ toastIcon: String,
        _ toastIconColor: Color,
        toastText: String,
        displayTime: DispatchTimeInterval,
        completion: (() -> Void)?
    )

    func displayToast(toastText: String)

    func showUnableToGetSoundAlert(_ soundTitle: String)
}
