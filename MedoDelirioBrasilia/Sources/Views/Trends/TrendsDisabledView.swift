//
//  TrendsDisabledView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 07/06/22.
//

import SwiftUI

struct TrendsDisabledView: View {

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 70))
                .foregroundColor(.accentColor)
                .frame(width: 100)
            
            Text("Tendências Desabilitado")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Para descobrir quais sons são mais compartilhados por você e pelos demais usuários do app, habilite o recurso Tendências \(UIDevice.current.userInterfaceIdiom == .phone ? "na aba" : "no menu") Ajustes.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Enquanto as tendências estiverem desabilitadas, nenhum dado de compartilhamento será coletado.")
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
