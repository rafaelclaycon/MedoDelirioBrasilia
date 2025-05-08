//
//  MoneyInfo.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 08/05/25.
//

import Foundation

struct MoneyInfo: Codable {

    let title: String
    let subtitle: String
    let currentValue: Double
    let totalValue: Double
    let type: String
}
