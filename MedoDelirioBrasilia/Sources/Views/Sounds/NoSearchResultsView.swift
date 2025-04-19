//
//  NoSearchResultsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/02/23.
//

import SwiftUI

struct NoSearchResultsView: View {

    let searchText: String

    var body: some View {
        VStack(alignment: .center, spacing: .spacing(.medium)) {
            Spacer(minLength: .spacing(.xxxLarge))

            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Nenhum Resultado para \"\(searchText)\"")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Verifique a ortografia ou tente uma nova busca.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer(minLength: .spacing(.xxxLarge))
        }
    }
}

#Preview {
    NoSearchResultsView(searchText: "Testeeee")
}
