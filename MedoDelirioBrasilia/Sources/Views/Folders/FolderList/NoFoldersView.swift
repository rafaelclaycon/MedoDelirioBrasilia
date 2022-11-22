//
//  NoFoldersView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 21/11/22.
//

import SwiftUI

struct NoFoldersView: View {

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            NoFoldersSymbol()
            
            Text("Nenhuma Pasta Criada (Ainda)")
                .font(.title3)
                .multilineTextAlignment(.center)
            
            Text("Pastas são uma maneira de organizar sons que você usa com frequência para acesso fácil.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("\(UIDevice.current.userInterfaceIdiom == .phone ? "Toque no + no canto superior direito para criar uma nova pasta de sons." : "Toque em Nova Pasta acima para criar uma nova pasta de sons.")")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
    }

}

struct NoFoldersView_Previews: PreviewProvider {

    static var previews: some View {
        NoFoldersView()
    }

}
