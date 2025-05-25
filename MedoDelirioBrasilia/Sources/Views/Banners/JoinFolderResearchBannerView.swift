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
                            await viewModel.onJoinResearchSelected()
                        }
                    },
                    onDontJoinSelected: {
                        AppPersistentMemory.shared.setHasDismissedJoinFolderResearchBanner(to: true)
                        displayMe = false
                    }
                )
            case .sendingInfo:
                SendingInfoView()
            case .doneSending:
                DoneSendingView(
                    isDark: colorScheme == .dark,
                    onCloseSelected: {
                        AppPersistentMemory.shared.setHasDismissedJoinFolderResearchBanner(to: true)
                        displayMe = false
                    }
                )
            case .errorSending:
                ErrorView(
                    isDark: colorScheme == .dark,
                    onCloseSelected: {
                        AppPersistentMemory.shared.setHasDismissedJoinFolderResearchBanner(to: true)
                        displayMe = false
                    },
                    onTryAgainSelected: {
                        Task {
                            await viewModel.onTryAgainSelected()
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

                VStack(alignment: .leading, spacing: 12) {
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
            VStack(spacing: 28) {
                ProgressView()
                    .scaleEffect(1.4, anchor: .center)

                Text("ENVIANDO INFORMAÇÕES...")
                    .font(.callout)
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
            }
            .padding(.vertical, 28)
            .frame(maxWidth: .infinity)
        }
    }

    struct DoneSendingView: View {

        let isDark: Bool
        let onCloseSelected: () -> Void

        var body: some View {
            VStack(spacing: 18) {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .foregroundColor(.green)

                Text("Você faz parte da pesquisa.")
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .bold()

                Text("PARA DESCADASTRAR, VÁ EM CONFIGURAÇÕES > PRIVACIDADE > PESQUISA SOBRE AS PASTAS.")
                    .font(.caption)
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .padding(.horizontal)
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .topTrailing) {
                Button {
                    onCloseSelected()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15)
                        .foregroundColor(isDark ? .primary : .gray)
                }
                .padding(.trailing, 10)
            }
        }
    }

    struct ErrorView: View {

        let isDark: Bool
        let onCloseSelected: () -> Void
        let onTryAgainSelected: () -> Void

        var body: some View {
            VStack(spacing: 18) {
                Image(systemName: "network.slash")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)

                Text("Erro ao tentar enviar.")
                    .multilineTextAlignment(.center)
                    .font(.title3)

                Text("Você pode tente novamente agora ou mais tarde em Configurações > Privacidade > Pesquisa Sobre as Pastas.")
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
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .topTrailing) {
                Button {
                    onCloseSelected()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15)
                        .foregroundColor(isDark ? .primary : .gray)
                }
                .padding(.trailing, 10)
            }
        }
    }
}

// MARK: - Previews

#Preview("Request to Join") {
    JoinFolderResearchBannerView(
        viewModel: JoinFolderResearchBannerView.ViewModel(state: .displayingRequestToJoin),
        displayMe: .constant(true)
    )
    .padding(.horizontal)
}

#Preview("Sending Info") {
    JoinFolderResearchBannerView(
        viewModel: JoinFolderResearchBannerView.ViewModel(state: .sendingInfo),
        displayMe: .constant(true)
    )
    .padding(.horizontal)
}

#Preview("Done Sending") {
    JoinFolderResearchBannerView(
        viewModel: JoinFolderResearchBannerView.ViewModel(state: .doneSending),
        displayMe: .constant(true)
    )
    .padding(.horizontal)
}

#Preview("Error") {
    JoinFolderResearchBannerView(
        viewModel: JoinFolderResearchBannerView.ViewModel(state: .errorSending),
        displayMe: .constant(true)
    )
    .padding(.horizontal)
}
