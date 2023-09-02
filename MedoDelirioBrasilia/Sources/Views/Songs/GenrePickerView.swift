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

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
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
                            }
                        }
                        .borderedButton(colored: .accentColor)
                    }

                    VStack {
                        ForEach(genres) { genre in
                            Button {
                                selectedId = genre.id
                                isBeingShown = false
                            } label: {
                                GenreRow(genre: genre, isSelected: selectedId == genre.id)
                            }
                            .foregroundColor(.primary)
                            .padding(.vertical, 5)
                            .padding(.horizontal)

                            Divider()
                                .padding(.horizontal)
                        }
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 13)
                            .fill(.gray.opacity(colorScheme == .dark ? 0.3 : 0.1))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
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

                if isSelected {
                    Text(genre.name)
                        .bold()
                        .multilineTextAlignment(.leading)
                } else {
                    Text(genre.name)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26)
                        .foregroundColor(.green)
                }
            }
            .padding(.vertical, 10)
        }
    }
}

struct GenrePickerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GenrePickerView(
                isBeingShown: .constant(true),
                selectedId: .constant(nil)
            )

            GenrePickerView(
                isBeingShown: .constant(true),
                selectedId: .constant("E4285AF9-0A57-4FED-933B-2379DC80BEEF")
            )
        }
    }
}
