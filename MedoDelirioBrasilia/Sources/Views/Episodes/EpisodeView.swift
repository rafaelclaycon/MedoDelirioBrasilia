//
//  EpisodeView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 25/10/22.
//

import SwiftUI

struct EpisodeView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("Medo e Delírio iOS não é um tocador de podcasts.")
            }
            .navigationTitle("Episódios")
        }
    }
}

struct EpisodeView_Previews: PreviewProvider {
    static var previews: some View {
        EpisodeView()
    }
}
