//
//  NoSoundsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/05/22.
//

import SwiftUI

struct NoSoundsView: View {

    @ScaledMetric private var vStackSpacing = 24
    @ScaledMetric private var iconSize = 70

    var body: some View {
        VStack(alignment: .center, spacing: vStackSpacing) {
            Image(systemName: "eye.slash.fill")
                .font(.system(size: iconSize))
                .foregroundColor(.blue)
            
            Text("Nenhum Som A Ser Exibido Para as Configurações Atuais")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Visite as Configurações aqui no app e habilite a opção **Exibir Conteúdo Explícito** para ver os sons desse autor.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }

}

struct NoSoundsView_Previews: PreviewProvider {

    static var previews: some View {
        NoSoundsView()
    }

}
