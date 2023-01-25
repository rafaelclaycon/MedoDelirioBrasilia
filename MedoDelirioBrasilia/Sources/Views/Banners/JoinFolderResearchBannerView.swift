import SwiftUI

struct JoinFolderResearchBannerView: View {

    @StateObject var viewModel: JoinFolderResearchBannerViewViewModel
    @Binding var displayMe: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var backgroundHeight: CGFloat {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            return 140
        }
        switch UIScreen.main.bounds.width {
        case 320:
            return 240
        case 428, 430:
            return 180
        default:
            return 200
        }
    }
    
    var backgroundOpacity: Double {
        if viewModel.state == .displayingRequestToJoin {
            return colorScheme == .dark ? 1.0 : 0.35
        } else {
            return colorScheme == .dark ? 0.5 : 0.15
        }
    }
    
    var buttonInternalPadding: CGFloat {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            return 20
        }
        switch UIScreen.main.bounds.width {
        case 320:
            return 0
        case 375:
            return 10
        default:
            return 20
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(viewModel.state == .displayingRequestToJoin ? Color.pastelBabyBlue : Color.gray)
                .opacity(backgroundOpacity)
                .frame(height: backgroundHeight)
            
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
            .frame(height: backgroundHeight)
            
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
                            .padding(.horizontal, buttonInternalPadding)
                    }
                    .font(.body)
                    .tint(colorScheme == .dark ? .mutedNavyBlue : .blue)
                    .controlSize(.regular)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle)
                    
                    Button {
                        AppPersistentMemory.setHasDismissedJoinFolderResearchBanner(to: true)
                        displayMe = false
                    } label: {
                        Text("Não")
                            .padding(.horizontal, buttonInternalPadding)
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
                        AppPersistentMemory.setHasDismissedJoinFolderResearchBanner(to: true)
                        displayMe = false
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
            .frame(height: backgroundHeight)
            
            VStack(spacing: 15) {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .foregroundColor(.green)
                
                Text("Enviado com sucesso!")
                    .multilineTextAlignment(.center)
                    .font(.title3)
                
                Text("Você faz parte da pesquisa. Para descadastrar, vá em Configurações > Privacidade > Pesquisa Sobre as Pastas.")
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder func getErrorSendingView() -> some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        AppPersistentMemory.setHasDismissedJoinFolderResearchBanner(to: true)
                        displayMe = false
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
            .frame(height: backgroundHeight)
            
            VStack(spacing: 12) {
                Image(systemName: "wifi.exclamationmark")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                
                Text("Erro ao tentar enviar.")
                    .multilineTextAlignment(.center)
                    .font(.title3)
                
                Text("Tente novamente mais tarde. Para cadastrar nas Configurações, vá em Privacidade > Pesquisa Sobre as Pastas.")
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .padding(.horizontal)
                
                Button {
                    viewModel.sendLogs()
                } label: {
                    Text("Tentar Novamente")
                        .padding(.horizontal, 10)
                }
                .font(.body)
                .tint(colorScheme == .dark ? .primary : .blue)
                .controlSize(.regular)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
            }
        }
    }

}

struct JoinFolderResearchBannerView_Previews: PreviewProvider {

    static var previews: some View {
        JoinFolderResearchBannerView(viewModel: JoinFolderResearchBannerViewViewModel(state: .displayingRequestToJoin), displayMe: .constant(true))
            .padding(.horizontal)
    }

}
