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
            
            Text("Para descobrir quais sons são mais compartilhados por você e pelos demais usuários do app, habilite o recurso Tendências na aba Ajustes.")
                .multilineTextAlignment(.center)
            
            Text("Enquanto as tendências estiverem desabilitadas, nenhum dado de compartilhamento será armazenado.")
                .multilineTextAlignment(.center)
        }
    }

}

struct TrendsDisabledView_Previews: PreviewProvider {

    static var previews: some View {
        TrendsDisabledView()
    }

}
