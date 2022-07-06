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
                
                Text("Oi! Eu sou Rafael, o criador do app.")
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 18) {
                Text("Existem alguns custos para o app estar aqui. Especificamente:\n\n · ~~a taxa de publicação (US$ 99/ano)~~ Taxa paga até 17/05/2023 pelas doações. **Vocês são demais!!!**\n\n · os custos mensais com servidor (cerca de R$ 30).")
            
                Text("Se você está curtindo o app e gostaria de ajudar, use a chave abaixo.")
            }
            
//            Text("**ÚLTIMA DOAÇÃO: SÉRGIO M. O.   R$ 20,00**")
//                .foregroundColor(.gray)
//                .multilineTextAlignment(.center)
//                .padding(.top, 15)
        }
    }

}

struct BegForMoneyView_Previews: PreviewProvider {

    static var previews: some View {
        BegForMoneyView()
    }

}
