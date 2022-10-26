//
//  Episode.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 25/10/22.
//

import Foundation

struct Episode: Hashable, Codable, Identifiable {

    var id: String
    var podcastId: Int
    var title: String
    var pubDate: Date?
    var duration: Double
    var originalRemoteUrl: String
    var spotifyLink: String
    var applePodcastsLink: String
    var pocketCastsLink: String
    
    init(id: String = UUID().uuidString,
         podcastId: Int = 0,
         title: String = .empty,
         pubDate: Date? = Date(),
         duration: Double = 0,
         originalRemoteUrl: String,
         spotifyLink: String = .empty,
         applePodcastsLink: String = .empty,
         pocketCastsLink: String = .empty) {
        self.id = id
        self.podcastId = podcastId
        self.title = title
        self.pubDate = pubDate
        self.duration = duration
        self.originalRemoteUrl = originalRemoteUrl
        self.spotifyLink = spotifyLink
        self.applePodcastsLink = applePodcastsLink
        self.pocketCastsLink = pocketCastsLink
    }

}

enum SortOption {

    case fromNewToOld, fromOldToNew

}

