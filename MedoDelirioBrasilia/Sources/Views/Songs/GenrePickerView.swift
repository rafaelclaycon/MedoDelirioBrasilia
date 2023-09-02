//
//  GenrePickerView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 01/09/23.
//

import SwiftUI

struct GenrePickerView: View {

    @Binding var isBeingShown: Bool
    @Binding var selectedId: String?

    @State private var genres: [MusicGenre] = []

    var body: some View {
        NavigationView {
            VStack {
                if selectedId != nil {
                    Button {
                        selectedId = nil
                        isBeingShown = false
                    } label: {
                        HStack(spacing: 15) {
                            Image(systemName: "x.circle")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)

                            Text("Remover filtro")
//                                .bold()
//                                .foregroundColor(.accentColor)
                        }
//                        .padding(.horizontal, 5)
//                        .padding(.vertical, 8)
                    }
                    .borderedButton(colored: .accentColor)
                }

                List {
                    ForEach(genres) { genre in
                        GenreRow(genre: genre, isSelected: selectedId == genre.id)
                            .onTapGesture {
                                selectedId = genre.id
                                isBeingShown = false
                            }
                    }
                }
                .navigationTitle("Filtrar por Gênero")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Fechar") {
                            isBeingShown = false
                        }
                    }
                }
            }
        }
        .onAppear {
            do {
                genres = try LocalDatabase.shared.musicGenres()
            } catch {
                print(error)
            }
        }
    }
}

extension GenrePickerView {

    struct GenreRow: View {

        let genre: MusicGenre
        let isSelected: Bool

        var body: some View {
            HStack(spacing: .zero) {
                Text(genre.symbol)
                    .font(.system(size: 30))
                
                Spacer()
                    .frame(width: 20)
                
                Text(genre.name)
                    .multilineTextAlignment(.leading)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundColor(.green)
                }
                
                Spacer(minLength: 0)
            }
            .padding(.vertical, 10)
        }
    }
}

struct GenrePickerView_Previews: PreviewProvider {
    static var previews: some View {
        GenrePickerView(
            isBeingShown: .constant(true),
            selectedId: .constant(nil)
        )
    }
}
