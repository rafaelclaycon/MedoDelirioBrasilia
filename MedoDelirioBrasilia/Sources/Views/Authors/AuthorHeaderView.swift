//
//  AuthorHeaderView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 19/04/25.
//

import SwiftUI
import Kingfisher

struct AuthorHeaderView: View {

    let author: Author
    let title: String
    let soundCount: Int
    let soundCountText: String

    let contentListMode: ContentListMode
    @Binding var contentSortOption: Int
    let multiSelectAction: () -> Void
    let askForSoundAction: () -> Void
    let reportIssueAction: () -> Void
    let contentSortChangeAction: () -> Void

    // MARK: - Computed Properties

    private func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }

    private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        // Image was pulled down
        if offset > 0 {
            return -offset
        }
        return 0
    }

    private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height
        if offset > 0 {
            return imageHeight + offset
        }
        return imageHeight
    }

    // MARK: - View Body

    var body: some View {
        VStack {
            if let photo = author.photo {
                GeometryReader { headerPhotoGeometry in
                    KFImage(URL(string: photo))
                        .placeholder {
                            Image(systemName: "photo.on.rectangle")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .foregroundColor(.gray)
                                .opacity(0.3)
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: headerPhotoGeometry.size.width,
                            height: self.getHeightForHeaderImage(headerPhotoGeometry)
                        )
                        .clipped()
                        .offset(x: 0, y: self.getOffsetForHeaderImage(headerPhotoGeometry))
                }
                .frame(height: 250)
            }

            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text(title)
                        .font(.title)
                        .bold()

                    Spacer()

                    MoreOptionsMenu(
                        soundCount: soundCount,
                        contentListMode: contentListMode,
                        contentSortOption: $contentSortOption,
                        multiSelectAction: multiSelectAction,
                        askForSoundAction: askForSoundAction,
                        reportIssueAction: reportIssueAction,
                        contentSortChangeAction: contentSortChangeAction
                    )
                }

                if let description = author.description {
                    Text(description)
                }

                if !author.links.isEmpty {
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 10) {
                            ForEach(author.links, id: \.title) {
                                ExternalLinkButton(externalLink: $0)
                            }
                        }
                        VStack(alignment: .leading, spacing: 15) {
                            ForEach(author.links, id: \.title) {
                                ExternalLinkButton(externalLink: $0)
                            }
                        }
                    }
                    .padding(.vertical, .spacing(.xxxSmall))
                }

                Text(soundCountText)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .bold()
            }
            .padding(.horizontal, .spacing(.large))
            .padding(.top, .spacing(.small))
            .padding(.bottom, .spacing(.xxSmall))
        }
    }
}

// MARK: - Subviews

extension AuthorHeaderView {

    struct MoreOptionsMenu: View {

        let soundCount: Int
        let contentListMode: ContentListMode
        @Binding var contentSortOption: Int
        let multiSelectAction: () -> Void
        let askForSoundAction: () -> Void
        let reportIssueAction: () -> Void
        let contentSortChangeAction: () -> Void

        var body: some View {
            Menu {
                if soundCount > 1 {
                    Section {
                        Button {
                            multiSelectAction()
                        } label: {
                            Label(
                                contentListMode == .selection ? "Cancelar Seleção" : "Selecionar",
                                systemImage: contentListMode == .selection ? "xmark.circle" : "checkmark.circle"
                            )
                        }
                    }
                }

                Section {
    //                Button {
    //                    contentListViewModel.onExitMultiSelectModeSelected()
    //                    viewModel.selectedSounds = viewModel.sounds
    //                    // showingAddToFolderModal = true // TODO: Fix - move to ContentList
    //                } label: {
    //                    Label("Adicionar Todos a Pasta", systemImage: "folder.badge.plus")
    //                }

                    Button {
                        askForSoundAction()
                    } label: {
                        Label("Pedir Som Desse Autor", systemImage: "plus.circle")
                    }

                    Button {
                        reportIssueAction()
                    } label: {
                        Label("Relatar Problema com os Detalhes Desse Autor", systemImage: "person.crop.circle.badge.exclamationmark")
                    }
                }

                if soundCount > 1 {
                    Section {
                        Picker("Ordenação de Sons", selection: $contentSortOption) {
                            Text("Título")
                                .tag(0)

                            Text("Mais Recentes no Topo")
                                .tag(1)
                        }
                        .onChange(of: contentSortOption) {
                            contentSortChangeAction()
                        }
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 26)
            }
            .disabled(soundCount == 0)
        }
    }
}

// MARK: - Preview

#Preview {
    let author = Author(id: "abc", name: "Atila Iamarino")

    return AuthorHeaderView(
        author: author,
        title: author.name,
        soundCount: 10,
        soundCountText: "10 SONS",
        contentListMode: .regular,
        contentSortOption: .constant(0),
        multiSelectAction: {},
        askForSoundAction: {},
        reportIssueAction: {},
        contentSortChangeAction: {}
    )
}
