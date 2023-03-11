//
//  PlaylistsCasingWithCloseView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 11/03/23.
//

import SwiftUI

struct PlaylistsCasingWithCloseView: View {
    
    @Binding var isBeingShown: Bool
    
    var body: some View {
        NavigationView {
            PlaylistList()
                .navigationTitle("Playlists")
                .navigationBarItems(leading:
                    Button("Fechar") {
                        self.isBeingShown = false
                    }
                )
        }
    }
}

struct PlaylistsCasingWithCloseView_Previews: PreviewProvider {
    
    static var previews: some View {
        PlaylistsCasingWithCloseView(isBeingShown: .constant(true))
    }
}
