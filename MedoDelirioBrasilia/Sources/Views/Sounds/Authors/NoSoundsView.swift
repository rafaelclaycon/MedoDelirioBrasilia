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
            
            Text("Visite a aba Ajustes e habilite a opção Exibir Conteúdo Sensível para ver os sons desse autor.")
                .multilineTextAlignment(.center)
        }
    }

}

struct NoSoundsView_Previews: PreviewProvider {

    static var previews: some View {
        NoSoundsView()
    }

}
