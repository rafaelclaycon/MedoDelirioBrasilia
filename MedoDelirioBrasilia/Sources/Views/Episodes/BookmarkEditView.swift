//
//  BookmarkEditView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/02/26.
//

import SwiftUI

struct BookmarkEditView: View {

    @Environment(EpisodeBookmarkStore.self) private var bookmarkStore
    @Environment(\.dismiss) private var dismiss

    let bookmark: EpisodeBookmark

    @State private var title: String
    @State private var note: String
    @State private var showDeleteConfirmation = false


    init(bookmark: EpisodeBookmark) {
        self.bookmark = bookmark
        _title = State(initialValue: bookmark.title ?? "")
        _note = State(initialValue: bookmark.note ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "bookmark.fill")
                            .foregroundStyle(Color.rubyRed)
                        Text(bookmark.formattedTimestamp)
                            .monospacedDigit()
                    }
                }

                Section("Título") {
                    TextField("Título", text: $title)
                }

                Section("Anotação") {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Excluir Marcador", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Editar Marcador")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        saveAndDismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .confirmationDialog(
                "Excluir este marcador?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Excluir", role: .destructive) {
                    bookmarkStore.delete(id: bookmark.id, episodeId: bookmark.episodeId)
                    dismiss()
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func saveAndDismiss() {
        var updated = bookmark
        updated.title = title.isEmpty ? nil : title
        updated.note = note.isEmpty ? nil : note
        bookmarkStore.update(updated)
        dismiss()
    }
}
