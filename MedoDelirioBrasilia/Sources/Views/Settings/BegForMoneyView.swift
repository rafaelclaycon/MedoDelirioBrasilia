import SwiftUI

struct BegForMoneyView: View {

    var body: some View {
        VStack(alignment: .center, spacing: 18) {
            HStack(spacing: 15) {
                Image("creator")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 80)
                
                Text("Oi! Eu sou Rafael, o criador dos apps do Medo e Delírio para **iPhone, iPad e Mac**.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 15)
            }
            
            VStack(alignment: .leading, spacing: 18) {
                Text("Sou um único desenvolvedor dedicando meu tempo livre para um projeto no qual acredito.")
            
                Text("Se você está curtindo o app e gostaria de ajudar, use a chave abaixo. Assim você garante novos sons, recursos e o meu muito obrigado!")
            }
        }
    }

}

struct BegForMoneyView_Previews: PreviewProvider {

    static var previews: some View {
        BegForMoneyView()
    }

}
