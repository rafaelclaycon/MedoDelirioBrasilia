//
//  StandaloneAuthorsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 12/04/25.
//

import SwiftUI

struct StandaloneAuthorsView: View {

    @State private var authorSortOption: Int = UserSettings().authorSortOption()

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                AuthorsView(
                    sortOption: $authorSortOption,
                    sortAction: .constant(.nameAscending),
                    searchTextForControl: .constant(""),
                    containerWidth: geometry.size.width
                )
            }
            .navigationTitle(Text("Autores"))
        }
    }
}

#Preview {
    StandaloneAuthorsView()
}
