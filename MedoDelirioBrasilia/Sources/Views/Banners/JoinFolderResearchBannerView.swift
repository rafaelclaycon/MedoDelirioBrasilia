import SwiftUI

struct JoinFolderResearchBannerView: View {

    @StateObject var viewModel: ViewModel

    @Binding var displayMe: Bool

    @Environment(\.colorScheme) var colorScheme

    var backgroundOpacity: Double {
        if viewModel.state == .displayingRequestToJoin {
            return colorScheme == .dark ? 1.0 : 0.35
        } else {
            return colorScheme == .dark ? 0.5 : 0.15
        }
    }

    var body: some View {
        VStack {
            switch viewModel.state {
            case .displayingRequestToJoin:
                RequestToJoinView(
                    isDark: colorScheme == .dark,
                    onJoinResearchSelected: {
                        Task {
                            await viewModel.sendLogs()
                        }
                    },
                    onDontJoinSelected: {
                        AppPersistentMemory.setHasDismissedJoinFolderResearchBanner(to: true)
                        displayMe = false
                    }
                )
            case .sendingInfo:
                SendingInfoView()
            case .doneSending:
                DoneSendingView(
                    isDark: colorScheme == .dark,
                    onCloseSelected: {
                        AppPersistentMemory.setHasDismissedJoinFolderResearchBanner(to: true)
                        displayMe = false
                    }
                )
            case .errorSending:
                ErrorView(
                    isDark: colorScheme == .dark,
                    onCloseSelected: {
                        AppPersistentMemory.setHasDismissedJoinFolderResearchBanner(to: true)
                        displayMe = false
                    },
                    onTryAgainSelected: {
                        Task {
                            await viewModel.sendLogs()
                        }
                    }
                )
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(viewModel.state == .displayingRequestToJoin ? Color.pastelBabyBlue : Color.gray)
                .opacity(backgroundOpacity)
        }
    }
}

extension JoinFolderResearchBannerView {

    struct RequestToJoinView: View {

        let isDark: Bool
        let onJoinResearchSelected: () -> Void
        let onDontJoinSelected: () -> Void

        var body: some View {
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
                    Text("Participe da Pesquisa")
                        .font(.headline)
                        .foregroundColor(.mutedNavyBlue)

                    Text("Ao enviar informações das suas pastas anonimamente, você me ajuda a entender o uso dessa funcionalidade para que eu possa melhorá-la no futuro.")
                        .font(.callout)
                        .foregroundColor(.mutedNavyBlue)
                        .opacity(isDark ? 1.0 : 0.75)

                    HStack(spacing: 15) {
                        Button {
                            onJoinResearchSelected()
                        } label: {
                            Text("Participar")
                                .padding(.horizontal)
                        }
                        .font(.body)
                        .tint(isDark ? .mutedNavyBlue : .blue)
                        .controlSize(.regular)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle)

                        Button {
                            onDontJoinSelected()
                        } label: {
                            Text("Não")
                                .padding(.horizontal)
                        }
                        .font(.body)
                        .tint(isDark ? .mutedNavyBlue : .blue)
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

    struct SendingInfoView: View {

        var body: some View {
            VStack(spacing: 35) {
                ProgressView()
                    .scaleEffect(2, anchor: .center)

                Text("Enviando informações...")
                    .multilineTextAlignment(.center)
            }
        }
    }

    struct DoneSendingView: View {

        let isDark: Bool
        let onCloseSelected: () -> Void

        var body: some View {
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            onCloseSelected()
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15)
                                .foregroundColor(isDark ? .primary : .gray)
                        }
                        .padding(.top)
                        .padding(.trailing)
                    }
                    Spacer()
                }

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
    }

    struct ErrorView: View {

        let isDark: Bool
        let onCloseSelected: () -> Void
        let onTryAgainSelected: () -> Void

        var body: some View {
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            onCloseSelected()
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15)
                                .foregroundColor(isDark ? .primary : .gray)
                        }
                        .padding(.top)
                        .padding(.trailing)
                    }
                    Spacer()
                }

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
                        onTryAgainSelected()
                    } label: {
                        Text("Tentar Novamente")
                            .padding(.horizontal, 10)
                    }
                    .font(.body)
                    .tint(isDark ? .primary : .blue)
                    .controlSize(.regular)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    JoinFolderResearchBannerView(
        viewModel: JoinFolderResearchBannerView.ViewModel(state: .displayingRequestToJoin),
        displayMe: .constant(true)
    )
    .padding(.horizontal)
}
