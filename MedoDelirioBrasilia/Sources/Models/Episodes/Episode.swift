//
//  Episode.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 25/10/22.
//

import Foundation

struct Episode: Hashable, Codable, Identifiable {

    var id: String
    var episodeId: String
    var title: String
    var description: String
    var pubDate: String
    var duration: Double
    var creationDate: String
    var spotifyLink: String
    var applePodcastsLink: String
    var pocketCastsLink: String
    
    init(id: String = UUID().uuidString,
         episodeId: String,
         title: String,
         description: String,
         pubDate: String,
         duration: Double,
         creationDate: String,
         spotifyLink: String = .empty,
         applePodcastsLink: String = .empty,
         pocketCastsLink: String = .empty) {
        self.id = id
        self.episodeId = episodeId
        self.title = title
        self.description = description
        self.pubDate = pubDate
        self.duration = duration
        self.creationDate = creationDate
        self.spotifyLink = spotifyLink
        self.applePodcastsLink = applePodcastsLink
        self.pocketCastsLink = pocketCastsLink
    }

}

enum SortOption {

    case fromNewToOld, fromOldToNew

}

