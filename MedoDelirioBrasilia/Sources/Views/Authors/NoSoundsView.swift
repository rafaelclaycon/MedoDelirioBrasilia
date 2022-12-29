//
//  NoSoundsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/05/22.
//

import SwiftUI

struct NoSoundsView: View {

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "eye.slash.fill")
                .font(.system(size: 70))
                .foregroundColor(.blue)
                .frame(width: 100)
            
            Text("Nenhum Som A Ser Exibido Para os Ajustes Atuais")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Visite os Ajustes aqui no app e habilite a opção Exibir Conteúdo Explícito para ver os sons desse autor.")
                .multilineTextAlignment(.center)
        }
    }

}

struct NoSoundsView_Previews: PreviewProvider {

    static var previews: some View {
        NoSoundsView()
    }

}
