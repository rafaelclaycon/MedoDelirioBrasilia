//
//  SoundsSearchResults.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/02/23.
//

import SwiftUI

struct SoundsSearchResults: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sons")
                .font(.title)
            
            Text("Autores")
                .font(.title)
        }
        .background(Color.systemBackground)
    }
    
}

struct SoundsSearchResults_Previews: PreviewProvider {
    
    static var previews: some View {
        SoundsSearchResults()
    }
    
}
