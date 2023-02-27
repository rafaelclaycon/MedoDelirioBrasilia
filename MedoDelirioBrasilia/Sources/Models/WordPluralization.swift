//
//  WordPluralization.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 02/02/23.
//

import Foundation

enum WordPluralization {

    case singular, plural

}

extension WordPluralization {
    
    func getAddedToFolderToastText(folderName: String?) -> String {
        switch self {
        case .singular:
            return "Som adicionado à pasta \(folderName ?? .empty)."
        case .plural:
            return "Sons adicionados à pasta \(folderName ?? .empty)."
        }
    }
    
    func getAddedToPlaylistToastText(playlistName: String?) -> String {
        switch self {
        case .singular:
            return "Som adicionado à playlist \(playlistName ?? .empty)."
        case .plural:
            return "Sons adicionados à playlist \(playlistName ?? .empty)."
        }
    }
    
}
