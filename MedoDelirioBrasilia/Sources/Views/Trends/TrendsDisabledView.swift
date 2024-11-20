//
//  TrendsDisabledView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 07/06/22.
//

import SwiftUI

struct TrendsDisabledView: View {

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 70))
                .foregroundColor(.accentColor)
            
            Text("Tendências Desabilitado")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Para descobrir quais sons são mais compartilhados por você e pelos demais usuários do app, habilite o recurso Tendências em Configurações > Privacidade.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Enquanto as tendências estiverem desabilitadas, nenhum dado de compartilhamento será coletado.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

}

struct TrendsDisabledView_Previews: PreviewProvider {

    static var previews: some View {
        TrendsDisabledView()
    }

}
