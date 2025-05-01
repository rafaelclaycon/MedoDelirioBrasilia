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
            if let content = results.content {
                ForEach(content) { item in
                    PlayableContentView(
                        content: item,
                        favorites: Set<String>(arrayLiteral: ""),
                        highlighted: Set<String>(arrayLiteral: ""),
                        nowPlaying: Set<String>(arrayLiteral: ""),
                        selectedItems: Set<String>(arrayLiteral: ""),
                        currentContentListMode: .constant(.regular)
                    )
                    .searchCompletion(item)
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
