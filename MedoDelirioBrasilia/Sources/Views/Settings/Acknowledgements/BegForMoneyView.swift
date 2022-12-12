import SwiftUI
import MarqueeText

struct BegForMoneyView: View {

    var body: some View {
        VStack(alignment: .center, spacing: 18) {
            HStack(spacing: 20) {
                Image("creator")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 80)
                
                Text("Rafael aqui, criador do app Medo e Delírio para iPhone, iPad e Mac.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 15)
            }
            
            VStack(alignment: .leading, spacing: 18) {
                Text("Esse trabalho é voluntário e envolve custos mensais com servidor (~R$ 30). Qualquer tipo de contribuição é bem-vinda!")
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("**Últimas contribuições:**")
                
                MarqueeText(text: "Roberto B. E. T.     Carolina P. L.     Pedro O. R.     Maria Augusta M. C.     Luiz Fernando L. F.",
                            font: UIFont.preferredFont(forTextStyle: .body),
                            leftFade: 16,
                            rightFade: 16,
                            startDelay: 1)
                    .padding(.bottom, -5)
            }
        }
    }

}

struct BegForMoneyView_Previews: PreviewProvider {

    static var previews: some View {
        BegForMoneyView()
    }

}
