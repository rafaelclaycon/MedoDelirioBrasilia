//
//  ReactionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 13/06/22.
//

import SwiftUI

struct ReactionsView: View {

    @StateObject private var viewModel = CollectionsViewViewModel()
    
    @State private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(viewModel.reactions) { reaction in
                    NavigationLink {
                        ReactionDetailView(
                            viewModel: .init(reaction: reaction)
                        )
                    } label: {
                        ReactionCell(reaction: reaction)
                    }
                }
            }
            .padding()
            .navigationTitle("Reações")
            .onAppear {
                viewModel.reloadCollectionList(withCollections: localMock())
            }
        }
    }
    
    private func localMock() -> [Reaction] {
        var array = [Reaction]()
        array.append(contentsOf: [
            .greetingsMock,
            .classicsMock,
            .choqueMock,
            .viralMock,
            .seriousMock,
            .enthusiasmMock,
            .acidMock,
            .sarcasticMock,
            .provokingMock,
            .slogansMock,
            .frustrationMock,
            .hopeMock,
            .surpriseMock,
            .ironyMock,
            .covid19Mock,
            .foreignMock,
            .lgbtMock,
            .jinglesMock
        ])
        return array
    }

}

#Preview {
    ReactionsView()
}
