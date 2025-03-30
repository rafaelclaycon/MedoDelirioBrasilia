//
//  ContextMenuOption.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/24.
//

import UIKit

struct ContextMenuOption: Identifiable {

    let id: UUID = UUID()
    let symbol: (Bool) -> String
    let title: (Bool) -> String
    let action: (AnyEquatableMedoContent, ContentListDisplaying) -> Void
}

struct ContextMenuSection {

    let title: String
    let options: (AnyEquatableMedoContent) -> [ContextMenuOption]
}

extension ContextMenuOption {

    static var shareSound: ContextMenuOption {
        ContextMenuOption(
            symbol: { _ in "square.and.arrow.up" },
            title: { _ in Shared.shareSoundButtonText }
        ) { content, delegate in
            delegate.share(content: content)
        }
    }

    static var shareAsVideo: ContextMenuOption {
        ContextMenuOption(
            symbol: { _ in "film"},
            title: { _ in Shared.shareAsVideoButtonText }
        ) { content, delegate in
            delegate.openShareAsVideoModal(for: content)
        }
    }

    static var addToFavorites: ContextMenuOption {
        return ContextMenuOption(
            symbol: { isFavorite in
                isFavorite ? "star.slash" : "star"
            },
            title: { isFavorite in
                isFavorite ? Shared.removeFromFavorites : Shared.addToFavorites
            }
        ) { content, delegate in
            delegate.toggleFavorite(content.id)
        }
    }

    static var addToFolder: ContextMenuOption {
        ContextMenuOption(
            symbol: { _ in "folder.badge.plus" },
            title: { _ in Shared.addToFolderButtonText }
        ) { content, delegate in
            delegate.addToFolder(content)
        }
    }

    static var viewAuthor: ContextMenuOption {
        ContextMenuOption(
            symbol: { _ in "person" },
            title: { _ in "Ver Autor" }
        ) { content, delegate in
            guard !content.authorId.isEmpty else { return }
            delegate.showAuthor(withId: content.authorId)
        }
    }

    static var viewDetails: ContextMenuOption {
        ContextMenuOption(
            symbol: { _ in "info.circle" },
            title: { _ in "Ver Detalhes" }
        ) { content, delegate in
            delegate.showDetails(for: content)
        }
    }
}

// MARK: - Folder Options

extension ContextMenuOption {

    static var playFromThisSound: ContextMenuOption {
        ContextMenuOption(
            symbol: { _ in "play"},
            title: { _ in "Tocar a Partir Desse"}
        ) { content, delegate in
            delegate.playFrom(content: content)
        }
    }

    static var removeSoundFromFolder: ContextMenuOption {
        ContextMenuOption(
            symbol: { _ in "folder.badge.minus"},
            title: { _ in "Remover da Pasta"}
        ) { content, delegate in
            delegate.removeFromFolder(content)
        }
    }
}

// MARK: - Author Options

extension ContextMenuOption {

    static var suggestOtherAuthorName: ContextMenuOption {
        ContextMenuOption(
            symbol: { _ in "exclamationmark.bubble"},
            title: { _ in "Sugerir Outro Nome de Autor"}
        ) { content, delegate in
            delegate.suggestOtherAuthorName(for: content)
        }
    }
}

extension ContextMenuSection {

    static func sharingOptions() -> ContextMenuSection {
        return ContextMenuSection(
            title: "Sharing",
            options: { _ in
                [
                    .shareSound,
                    .shareAsVideo
                ]
            }
        )
    }

    static func organizingOptions() -> ContextMenuSection {
        return ContextMenuSection(
            title: "Organizing",
            options: { _ in
                [
                    ContextMenuOption.addToFavorites,
                    ContextMenuOption.addToFolder
                ]
            }
        )
    }

    static func detailsOptions() -> ContextMenuSection {
        return ContextMenuSection(
            title: "Details",
            options: { _ in
                [
                    ContextMenuOption.viewAuthor,
                    ContextMenuOption.viewDetails
                ]
            }
        )
    }

    static func playFromThisSound() -> ContextMenuSection {
        return ContextMenuSection(
            title: "PlayFromThis",
            options: { _ in
                [
                    ContextMenuOption.playFromThisSound
                ]
            }
        )
    }

    static func removeFromFolder() -> ContextMenuSection {
        return ContextMenuSection(
            title: "RemoveFromFolder",
            options: { _ in
                [
                    ContextMenuOption.removeSoundFromFolder
                ]
            }
        )
    }

    static func authorOptions() -> ContextMenuSection {
        return ContextMenuSection(
            title: "AuthorOptions",
            options: { _ in
                [
                    ContextMenuOption.suggestOtherAuthorName,
                    ContextMenuOption.viewDetails
                ]
            }
        )
    }
}
