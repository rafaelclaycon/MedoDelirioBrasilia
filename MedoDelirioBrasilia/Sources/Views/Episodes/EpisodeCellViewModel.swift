//
//  EpisodeCellViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/10/22.
//

import Combine
import Foundation

class EpisodeCellViewModel: ObservableObject {

    var episodeID: String
    
    @Published var title: String
    @Published var description: String
    @Published var subtitle: String
    
    init(episode: Episode, selected: Bool = false) {
        episodeID = episode.id
        title = episode.title
        description = episode.description
        subtitle = (episode.pubDate.iso8601withFractionalSeconds?.asShortString() ?? .empty)  + " - " + episode.duration.toDisplayString()
    }

}
