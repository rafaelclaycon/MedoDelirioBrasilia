//
//  TopChartItem.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 29/05/22.
//

import Foundation

struct TopChartItem: Hashable, Codable, Identifiable {

    var id: String
    var rankNumber: String
    var contentId: String
    var contentName: String
    var contentAuthorId: String
    var contentAuthorName: String
    var shareCount: Int

}
