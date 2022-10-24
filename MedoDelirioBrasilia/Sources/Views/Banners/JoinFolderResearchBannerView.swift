import SwiftUI

struct JoinFolderResearchBannerView: View {

    @StateObject var viewModel: JoinFolderResearchBannerViewViewModel
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
                .fill(viewModel.state == .displayingRequestToJoin ? Color.pastelBabyBlue : Color.gray)
                .opacity(colorScheme == .dark ? 1.0 : 0.35)
                .frame(height: roundedRectangleHeight)
            
            switch viewModel.state {
            case .displayingRequestToJoin:
                getRequestToJoinView()
            case .sendingInfo:
                getSendingInfoView()
            case .doneSending:
                getDoneSendingView()
            case .errorSending:
                getErrorSendingView()
            }
        }
    }
    
    @ViewBuilder func getRequestToJoinView() -> some View {
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
                
                HStack(spacing: 15) {
                    Button {
                        viewModel.sendLogs()
                    } label: {
                        Text("Participar")
                            .padding(.horizontal, 20)
                    }
                    .font(.body)
                    .tint(colorScheme == .dark ? .mutedNavyBlue : .blue)
                    .controlSize(.regular)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle)
                    
                    Button {
                        print("Não")
                    } label: {
                        Text("Não")
                            .padding(.horizontal, 20)
                    }
                    .font(.body)
                    .tint(colorScheme == .dark ? .mutedNavyBlue : .blue)
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
    
    @ViewBuilder func getSendingInfoView() -> some View {
        VStack(spacing: 35) {
            ProgressView()
                .scaleEffect(2, anchor: .center)
            
            Text("Enviando informações...")
                .multilineTextAlignment(.center)
        }
    }
    
    @ViewBuilder func getDoneSendingView() -> some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        print("Closed")
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15)
                            .foregroundColor(colorScheme == .dark ? .primary : .gray)
                    }
                    .padding(.top)
                    .padding(.trailing)
                }
                Spacer()
            }
            .frame(height: roundedRectangleHeight)
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .foregroundColor(.green)
                
                Text("Enviado com sucesso!")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                
                Text("Você faz parte da pesquisa. Para descadastrar, vá em Ajustes > Privacidade > Pesquisa sobre as Pastas.")
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder func getErrorSendingView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
            
            Text("Erro ao tentar enviar.")
                .multilineTextAlignment(.center)
                .font(.title3)
            
            Text("Tente novamente mais tarde. Para cadastrar nos Ajustes, vá em Privacidade > Pesquisa sobre as Pastas.")
                .multilineTextAlignment(.center)
                .font(.footnote)
                .padding(.horizontal)
        }
    }

}

struct JoinFolderResearchBannerView_Previews: PreviewProvider {

    static var previews: some View {
        JoinFolderResearchBannerView(viewModel: JoinFolderResearchBannerViewViewModel(state: .doneSending), displayMe: .constant(true))
            .padding(.horizontal)
    }

}
