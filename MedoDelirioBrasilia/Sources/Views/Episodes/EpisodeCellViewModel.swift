//
//  EpisodeCellViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/10/22.
//

import Combine
import Foundation

class EpisodeCellViewModel: ObservableObject {

    var podcastID: Int
    var episodeID: String
    
    @Published var title: String
    @Published var subtitle: String
    
    init(episode: Episode, selected: Bool = false) {
        podcastID = episode.podcastId
        episodeID = episode.id

        title = episode.title
        subtitle = (episode.pubDate?.asShortString() ?? .empty)  + " - " + episode.duration.toDisplayString()
    }

}
