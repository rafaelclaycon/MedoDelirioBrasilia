//
//  TrendsTimeInterval.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 12/10/22.
//

import Foundation

enum TrendsTimeInterval: Int {

    case last24Hours
    case last3Days
    case lastWeek
    case lastMonth
    case year2025
    case year2024
    case year2023
    case year2022
    case allTime
}

enum TrendsContentType {

    case sounds, songs
}
