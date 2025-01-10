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
    let action: (Sound, SoundListDisplaying) -> Void
}

struct ContextMenuSection {
    let title: String
    let options: (Sound) -> [ContextMenuOption]
}

extension ContextMenuOption {

    static var shareSound: ContextMenuOption {
        ContextMenuOption(
            symbol: { _ in "square.and.arrow.up" },
            title: { _ in Shared.shareSoundButtonText }
        ) { sound, delegate in
            delegate.share(sound: sound)
        }
    }

    static var shareAsVideo: ContextMenuOption {
        ContextMenuOption(
            symbol: { _ in "film"},
            title: { _ in Shared.shareAsVideoButtonText }
        ) { sound, delegate in
            delegate.openShareAsVideoModal(for: sound)
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
        ) { sound, delegate in
            delegate.toggleFavorite(sound.id)
        }
    }

    static var addToFolder: ContextMenuOption {
        ContextMenuOption(
            symbol: { _ in "folder.badge.plus" },
            title: { _ in Shared.addToFolderButtonText }
        ) { sound, delegate in
            delegate.addToFolder(sound)
        }
    }

    static var viewAuthor: ContextMenuOption {
        ContextMenuOption(
            symbol: { _ in "person" },
            title: { _ in "Ver Autor" }
        ) { sound, delegate in
            delegate.showAuthor(withId: sound.authorId)
        }
    }

    static var viewDetails: ContextMenuOption {
        ContextMenuOption(
            symbol: { _ in "info.circle" },
            title: { _ in "Ver Detalhes" }
        ) { sound, delegate in
            delegate.showDetails(for: sound)
        }
    }
}

// MARK: - Folder Options

extension ContextMenuOption {

    static var playFromThisSound: ContextMenuOption {
        ContextMenuOption(
            symbol: { _ in "play"},
            title: { _ in "Tocar a Partir Desse"}
        ) { sound, delegate in
            delegate.playFrom(sound: sound)
        }
    }

    static var removeSoundFromFolder: ContextMenuOption {
        ContextMenuOption(
            symbol: { _ in "folder.badge.minus"},
            title: { _ in "Remover da Pasta"}
        ) { sound, delegate in
            delegate.removeFromFolder(sound)
        }
    }
}

// MARK: - Author Options

extension ContextMenuOption {

    static var suggestOtherAuthorName: ContextMenuOption {
        ContextMenuOption(
            symbol: { _ in "exclamationmark.bubble"},
            title: { _ in "Sugerir Outro Nome de Autor"}
        ) { sound, delegate in
            delegate.suggestOtherAuthorName(for: sound)
        }
    }
}

extension ContextMenuSection {

    static func sharingOptions() -> ContextMenuSection {
        return ContextMenuSection(
            title: "Sharing",
            options: { sound in
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
