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
                
                Text("Oi! Eu sou Rafael, o criador do app Medo e Delírio para iPhone, iPad e Mac.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 15)
            }
            
            VStack(alignment: .leading, spacing: 18) {
                Text("Esse trabalho é voluntário e envolve custos mensais com servidor (~R$ 30). Se você quiser ajudar com um cafezinho ou um petisco, eu e a Wandinha agradecemos muito! 🐶")
                
                Text("Últimas contribuições:\n**Daniela C. B., Julio C. A., Bernardo P. M.** ❤️")
            }
        }
    }

}

struct BegForMoneyView_Previews: PreviewProvider {

    static var previews: some View {
        BegForMoneyView()
    }

}
