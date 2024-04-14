//
//  ContextMenuOption.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/24.
//

import Foundation

struct ContextMenuOption {
    let symbol: String
    let title: String
    let action: () -> Void
}

extension ContextMenuOption {

    static var shareSound: ContextMenuOption {
        ContextMenuOption(symbol: "square.and.arrow.up", title: "Share Sound") {
            // Implement the action to share sound
            print("Sharing Sound")
        }
    }

    static var shareAsVideo: ContextMenuOption {
        ContextMenuOption(symbol: "video", title: "Share as Video") {
            // Implement the action to share as video
            print("Sharing as Video")
        }
    }

    static var addToFavorites: ContextMenuOption {
        ContextMenuOption(symbol: "star", title: "Add to Favorites") {
            // Implement the action to add to favorites
            print("Added to Favorites")
        }
    }

    static var addToFolder: ContextMenuOption {
        ContextMenuOption(symbol: "folder", title: "Add to Folder") {
            // Implement the action to add to folder
            print("Added to Folder")
        }
    }

    static var viewAllFromThisAuthor: ContextMenuOption {
        ContextMenuOption(symbol: "person.2", title: "View All from Author") {
            // Implement the action to view all sounds from this author
            print("Viewing All from Author")
        }
    }

    static var viewDetails: ContextMenuOption {
        ContextMenuOption(symbol: "info.circle", title: "View Details") {
            // Implement the action to view details
            print("Viewing Details")
        }
    }
}
