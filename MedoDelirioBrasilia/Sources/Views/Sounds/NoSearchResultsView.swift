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
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("Nenhum Resultado")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Nenhum resultado encontrado para \"\(searchText)\".")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
}

struct NoSearchResultsView_Previews: PreviewProvider {
    
    static var previews: some View {
        NoSearchResultsView(searchText: .constant("Testeeee"))
    }
    
}
