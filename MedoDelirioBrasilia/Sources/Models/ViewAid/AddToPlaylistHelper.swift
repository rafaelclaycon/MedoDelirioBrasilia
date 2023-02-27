//
//  AddToPlaylistHelper.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/02/23.
//

import Foundation

class AddToPlaylistHelper: ObservableObject {
    
    @Published var selectedSounds: [Sound]? = nil
    @Published var playlistName: String = .empty
    @Published var pluralization: WordPluralization = .singular
    @Published var hadSuccess: Bool = false
    
}
