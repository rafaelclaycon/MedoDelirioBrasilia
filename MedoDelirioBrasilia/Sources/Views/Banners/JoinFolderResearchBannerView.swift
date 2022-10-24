import SwiftUI

struct JoinFolderResearchBannerView: View {

    @Binding var displayMe: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var roundedRectangleHeight: CGFloat {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            return 140
        }
        
        switch UIScreen.main.bounds.width {
        case 320:
            return 240
        case 428:
            return 180
        case 430:
            return 180
        default:
            return 200
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.pastelBabyBlue)
                .opacity(colorScheme == .dark ? 1.0 : 0.35)
                .frame(height: roundedRectangleHeight)
            
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15)
                        .foregroundColor(.blue)
                        .padding(.top)
                        .padding(.trailing)
                        .onTapGesture {
                            //didTapClose = true
                        }
                }
                Spacer()
            }
            
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
                .frame(height: roundedRectangleHeight)
                
                VStack(alignment: .leading, spacing: 7) {
                    Text("Participe da Pesquisa")
                        .font(.headline)
                        .foregroundColor(.mutedNavyBlue)
                    
                    Text("Ao enviar informações das suas pastas anonimamente, você me ajuda a entender o uso dessa funcionalidade para que eu possa melhorá-la no futuro.")
                        .font(.callout)
                        .foregroundColor(.mutedNavyBlue)
                        .opacity(colorScheme == .dark ? 1.0 : 0.75)
                    
                    Button {
                        print("Participar")
                    } label: {
                        Text("Participar")
                            .padding(.horizontal, 20)
                    }
                    .font(.body)
                    .tint(colorScheme == .dark ? .mutedNavyBlue : .blue)
                    .controlSize(.regular)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle)
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
            .padding(.horizontal)
    }

}
