//
//  StandaloneAuthorsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 12/04/25.
//

import SwiftUI

struct StandaloneAuthorsView: View {

    @State private var authorSortOption: Int = UserSettings().authorSortOption()
    @State private var authorGridViewModel: AuthorsGrid.ViewModel = AuthorsGrid.ViewModel(
        authorService: AuthorService(database: LocalDatabase.shared),
        userSettings: UserSettings(),
        sortOption: UserSettings().authorSortOption()
    )

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                AuthorsGrid(
                    viewModel: authorGridViewModel,
                    containerWidth: geometry.size.width
                )
                .padding(.horizontal, .spacing(.medium))
            }
            .navigationTitle(Text("Autores"))
            .toolbar {
                AuthorToolbarOptionsView(
                    authorSortOption: $authorSortOption,
                    onSortingChangedAction: {
                        authorGridViewModel.onAuthorSortingChangedExternally(authorSortOption)
                    }
                )
            }
        }
    }
}

#Preview {
    StandaloneAuthorsView()
}
