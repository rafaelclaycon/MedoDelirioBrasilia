//
//  GenrePickerView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 01/09/23.
//

import SwiftUI

struct GenrePickerView: View {

    @State private var genres: [MusicGenre] = []

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(genres) { genre in
                    GenreRow(genre: genre)
                        .onTapGesture {
                            print(genre.id)
                        }
                }
            }
            .navigationTitle("Filtrar por Gênero")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fechar") {
                        dismiss()
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

        var body: some View {
            HStack(spacing: .zero) {
                Text(genre.symbol)
                    .font(.system(size: 30))
                
                Spacer()
                    .frame(width: 20)
                
                Text(genre.name)
                    .multilineTextAlignment(.leading)
                
                Spacer(minLength: 0)
            }
            .padding(.vertical, 10)
        }
    }
}

struct GenrePickerView_Previews: PreviewProvider {
    static var previews: some View {
        GenrePickerView()
    }
}
