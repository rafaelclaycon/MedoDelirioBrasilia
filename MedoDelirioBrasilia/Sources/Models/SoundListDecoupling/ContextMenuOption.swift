//
//  ContextMenuOption.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/24.
//

import UIKit

struct ContextMenuOption {
    let symbol: String
    let title: String
    let action: (Sound, SoundListDisplaying) -> Void
}

struct ContextMenuSection {
    let title: String
    let options: (Sound) -> [ContextMenuOption]
}

extension ContextMenuOption {

    static var shareSound: ContextMenuOption {
        ContextMenuOption(symbol: "square.and.arrow.up", title: Shared.shareSoundButtonText) { sound, delegate in
            if UIDevice.isiPhone {
                do {
                    try SharingUtility.shareSound(from: sound.fileURL(), andContentId: sound.id) { didShare in
                        if didShare {
                            delegate.displayToast(toastText: Shared.soundSharedSuccessfullyMessage)
                        }
                    }
                } catch {
                    delegate.showUnableToGetSoundAlert(sound.title)
                }
            } else {
//                do {
//                    let url = try sound.fileURL()
//                    iPadShareSheet = ActivityViewController(activityItems: [url]) { activity, completed, items, error in
//                        if completed {
//                            self.isShowingShareSheet = false
//
//                            guard let activity = activity else {
//                                return
//                            }
//                            let destination = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
//                            Logger.shared.logSharedSound(contentId: sound.id, destination: destination, destinationBundleId: activity.rawValue)
//
//                            AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()
//
//                            self.displayToast(toastText: Shared.soundSharedSuccessfullyMessage)
//                        }
//                    }
//                } catch {
//                    showUnableToGetSoundAlert(sound.title)
//                }
//
//                isShowingShareSheet = true
            }
        }
    }

    static var shareAsVideo: ContextMenuOption {
        ContextMenuOption(symbol: "film", title: Shared.shareAsVideoButtonText) { sound, delegate in
            delegate.openShareAsVideoModal(for: sound)
        }
    }

    static var addToFavorites: ContextMenuOption {
        ContextMenuOption(symbol: "star", title: Shared.addToFavorites) { sound, delegate in
            delegate.toggleFavorite(sound.id)
        }
    }

    static var addToFolder: ContextMenuOption {
        ContextMenuOption(symbol: "folder.badge.plus", title: Shared.addToFolderButtonText) { _,_ in
            // Implement the action to add to folder
            print("Added to Folder")
        }
    }

    static var viewAllFromThisAuthor: ContextMenuOption {
        ContextMenuOption(symbol: "person", title: "Ver Todos os Sons Desse Autor") { _,_ in
            // Implement the action to view all sounds from this author
            print("Viewing All from Author")
        }
    }

    static var viewDetails: ContextMenuOption {
        ContextMenuOption(symbol: "info.circle", title: "Ver Detalhes") { _,_ in
            // Implement the action to view details
            print("Viewing Details")
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
                    ContextMenuOption.viewAllFromThisAuthor,
                    ContextMenuOption.viewDetails
                ]
            }
        )
    }
}
