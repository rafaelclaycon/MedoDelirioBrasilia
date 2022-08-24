import SwiftUI

struct TipView: View {

    @Binding var text: String
    
    var roundedRectangleHeight: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            switch UIScreen.main.bounds.width {
            case 320: // iPod touch 7
                return 204
            case 375: // iPhone 8
                return 164
            case 390: // iPhone 13
                return 160
            default: // iPhone 11, 13 Pro Max
                return 150
            }
        } else {
            return 100
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.yellow)
                .frame(height: roundedRectangleHeight)
            
            HStack(spacing: 20) {
                Image(systemName: "lightbulb")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 7) {
                    Text("Dica")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text(text)
                        .foregroundColor(.black)
                        .font(.callout)
                        .opacity(0.9)
                }
                
                Spacer()
            }
            .padding(.leading, 20)
        }
    }

}

struct TwitterReplyTipView_Previews: PreviewProvider {

    static var previews: some View {
        TipView(text: .constant("Para responder um tuíte, escolha Salvar Vídeo na tela de compartilhamento. Depois, adicione o vídeo ao seu tuíte de dentro do Twitter."))
    }

}
