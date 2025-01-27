//
//  SearchResultsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/01/25.
//

import SwiftUI

struct SearchResultsView: View {

    let results: SearchResults

    var body: some View {
        VStack {
            if let sounds = results.sounds {
                ForEach(sounds) { sound in
                    SoundItem(
                        sound: sound,
                        favorites: .constant(Set<String>(arrayLiteral: "")),
                        highlighted: .constant(Set<String>(arrayLiteral: "")),
                        nowPlaying: .constant(Set<String>(arrayLiteral: "")),
                        selectedItems: .constant(Set<String>(arrayLiteral: "")),
                        currentSoundsListMode: .constant(.regular)
                    )
                    .searchCompletion(sound)
                }
            }

            if let authors = results.authors {
                ForEach(authors) { author in
                    Text(author.name)
                    .searchCompletion(author)
                }
            }
        }
    }
}

#Preview {
    SearchResultsView(
        results: .init()
    )
}
