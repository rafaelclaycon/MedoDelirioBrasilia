import SwiftUI
#if os(iOS)
import MarqueeText
#endif

struct BegForMoneyView: View {

    var body: some View {
        VStack(alignment: .center, spacing: 18) {
            HStack(spacing: 15) {
                Image("creator")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 80)
                
                Text("Oi, aqui é o Rafael. Eu sou o criador do app Medo e Delírio para iPhone, iPad e Mac.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 15)
            }
            
            VStack(alignment: .leading, spacing: 18) {
                Text("Esse trabalho é voluntário e envolve custos mensais com servidor (~R$ 30). Quer ter seu nome aqui embaixo? Manda um cafezinho ou um petisco pra gente. Eu e a Wandinha agradecemos muito! 🐶")
                
                Text("**Últimas contribuições:**")
                
                #if os(iOS)
                MarqueeText(text: "Carlos Henrique P. M.     Beatriz F. F. N.     Luiz Fernando L. F.     Maria Augusta M. C.     Pedro O. R.",
                            font: UIFont.preferredFont(forTextStyle: .body),
                            leftFade: 16,
                            rightFade: 16,
                            startDelay: 1)
                    .padding(.bottom, -5)
                #endif
            }
        }
    }

}

struct BegForMoneyView_Previews: PreviewProvider {

    static var previews: some View {
        BegForMoneyView()
    }

}
