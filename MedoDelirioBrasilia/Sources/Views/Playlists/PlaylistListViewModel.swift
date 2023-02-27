//
//  PlaylistListViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/02/23.
//

import Foundation
import Combine

class PlaylistListViewModel: ObservableObject {
    
    @Published var playlists = [Playlist]()
    @Published var hasPlaylistsToDisplay: Bool = false
    
    //@Published var currentActivity: NSUserActivity? = nil
    
    // Alerts
//    @Published var alertTitle: String = ""
//    @Published var alertMessage: String = ""
//    @Published var showAlert: Bool = false
//    @Published var folderIdForDeletion: String = ""
    
    func reloadPlaylistList(withPlaylists outsidePlaylists: [Playlist]?) {
        guard let actualPlaylists = outsidePlaylists, actualPlaylists.count > 0 else {
            return hasPlaylistsToDisplay = false
        }
        self.playlists = actualPlaylists
        self.hasPlaylistsToDisplay = true
    }
    
}
