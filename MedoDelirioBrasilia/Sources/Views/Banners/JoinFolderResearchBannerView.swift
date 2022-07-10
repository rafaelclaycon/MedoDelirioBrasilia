import SwiftUI

struct JoinFolderResearchBannerView: View {

    @Binding var displayMe: Bool
    
    var roundedRectangleHeight: CGFloat {
        switch UIScreen.main.bounds.width {
        case 320:
            return 224
        case 375:
            return 184
        case 390:
            return 186
        default:
            return 170
        }
    }
    
    var buttonSpacing: CGFloat {
        switch UIScreen.main.bounds.width {
        case 320:
            return 15
        case 375:
            return 10
        case 390:
            return 15
        default:
            return 25
        }
    }
    
    var buttonFont: Font {
        switch UIScreen.main.bounds.width {
        case 320:
            return .callout
        case 375:
            return .body
        case 390:
            return .body
        default:
            return .body
        }
    }
    
    var noThanksButtonText: String {
        switch UIScreen.main.bounds.width {
        case 320:
            return "Não"
        case 375:
            return "Não, obrigado"
        case 390:
            return "Não, obrigado"
        default:
            return "Não, obrigado"
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.pastelBabyBlue)
                .frame(height: roundedRectangleHeight)
            
            HStack(spacing: 20) {
                VStack {
                    Image(systemName: "sparkle.magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .foregroundColor(.blue)
                        .padding(.top)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 7) {
                    Text("Participar da Pesquisa?")
                        .font(.headline)
                        .foregroundColor(.mutedNavyBlue)
                    
                    Text("Ao enviar o nome das suas pastas anonimamente, você nos ajuda a entender o uso da funcionalidade para que possamos aprimorá-la no futuro.")
                        .font(.callout)
                        .foregroundColor(.mutedNavyBlue)
                        .opacity(0.75)
                    
                    HStack(spacing: buttonSpacing) {
                        Button("Participar") {
                            print("Participar")
                        }
                        .font(buttonFont)
                        .tint(.blue)
                        .controlSize(.regular)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle)
                        
                        Button(noThanksButtonText) {
                            print("Não")
                        }
                        .font(buttonFont)
                        .tint(.blue)
                        .controlSize(.regular)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle)
                    }
                    .padding(.top, 2)
                }
                
                Spacer()
            }
            .padding(.leading, 20)
        }
    }

}

struct JoinFolderResearchBannerView_Previews: PreviewProvider {

    static var previews: some View {
        JoinFolderResearchBannerView(displayMe: .constant(true))
    }

}
