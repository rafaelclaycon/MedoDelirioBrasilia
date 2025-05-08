//
//  MoneyInfo.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 08/05/25.
//

import SwiftUI

struct MoneyInfo {

    let title: String
    let subtitle: String
    let currentValue: Double
    let totalValue: Double
    let barColor: Color
}

struct MoneyInfoDTO: Codable {

    let title: String
    let subtitle: String
    let currentValue: Double
    let totalValue: Double
    let barColor: String
}
