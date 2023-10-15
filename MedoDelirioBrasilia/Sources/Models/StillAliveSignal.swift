//
//  StillAliveSignal.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 27/10/22.
//

import Foundation

struct StillAliveSignal: Hashable, Codable {

    let installId: String
    let modelName: String
    let systemName: String
    let systemVersion: String
    let isiOSAppOnMac: Bool
    let appVersion: String
    let currentTimeZone: String
    let dateTime: String
    let appleWatchPaired: Bool
}
