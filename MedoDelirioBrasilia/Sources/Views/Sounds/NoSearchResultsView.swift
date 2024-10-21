//
//  NoSearchResultsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/02/23.
//

import SwiftUI

struct NoSearchResultsView: View {
    
    @Binding var searchText: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer(minLength: 40)

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
            
            Spacer(minLength: 40)
        }
    }
}

struct NoSearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        NoSearchResultsView(searchText: .constant("Testeeee"))
    }
}
