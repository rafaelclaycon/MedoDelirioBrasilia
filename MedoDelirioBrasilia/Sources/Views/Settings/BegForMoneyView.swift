import SwiftUI

struct BegForMoneyView: View {

    @State private var showPixKeyCopiedAlert: Bool = false
    
    let pixKey: String = "918bd609-04d1-4df6-8697-352b62462061"
    
    var body: some View {
        VStack(alignment: .center, spacing: 18) {
            
            HStack(spacing: 15) {
                Image("creator")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 80)
                    //.shadow(radius: 3, y: 2)
                
                Text("Oi! Eu sou Rafael, o criador do app.")
                    .multilineTextAlignment(.center)
            }
            
            Text("Existem alguns custos para o app estar aqui. Especificamente a taxa de publicação (US$ 99/ano) e os custos mensais com servidor (cerca de R$ 30).")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Se você está curtindo o app e gostaria de ajudar, use a chave abaixo. Assim você garante novos sons, recursos e o meu muito obrigado!")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                UIPasteboard.general.string = pixKey
                showPixKeyCopiedAlert = true
            }) {
                Text(pixKey)
                    .font(.subheadline)
                    .bold()
            }
            .tint(.blue)
            .controlSize(.large)
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle)
            .alert(isPresented: $showPixKeyCopiedAlert) {
                Alert(title: Text("Chave copiada com sucesso!"), dismissButton: .default(Text("OK")))
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
