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

    init(
        id: String,
        rankNumber: String,
        contentId: String,
        contentName: String,
        contentAuthorId: String,
        contentAuthorName: String,
        shareCount: Int
    ) {
        self.id = id
        self.rankNumber = rankNumber
        self.contentId = contentId
        self.contentName = contentName
        self.contentAuthorId = contentAuthorId
        self.contentAuthorName = contentAuthorName
        self.shareCount = shareCount
    }

    init(
        rankNumber: String,
        contentName: String
    ) {
        self.id = UUID().uuidString
        self.rankNumber = rankNumber
        self.contentId = ""
        self.contentName = contentName
        self.contentAuthorId = ""
        self.contentAuthorName = ""
        self.shareCount = 0
    }
}
