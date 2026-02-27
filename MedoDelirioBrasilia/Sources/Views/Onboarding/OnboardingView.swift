//
//  OnboardingView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/08/22.
//

import SwiftUI

// MARK: - Disabled Feature: Content Download Choice
// The following enum and views (AskDoFirstContentUpdateView, OptionBox) are preserved
// for a future feature that lets users choose when to download content on first launch.

enum ContentDownloadChoice {
    case downloadLater
    case downloadAllNow
}

enum OnboardingStep: Hashable {
    case explicitContent
    case notifications
    case episodeNotifications
}

struct OnboardingView: View {

    // NOTE: Content Download Choice feature is disabled for now.
    // The selectionAction and AskDoFirstContentUpdateView are preserved for future use.
    // var selectionAction: ((ContentDownloadChoice) -> Void)? = nil

    @State private var path = NavigationPath()

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeView {
                path.append(OnboardingStep.explicitContent)
            }
            .navigationDestination(for: OnboardingStep.self) { step in
                switch step {
                case .explicitContent:
                    AskShowExplicitContentView(
                        showAction: {
                            UserSettings().setShowExplicitContent(to: true)
                        },
                        advanceAction: {
                            path.append(OnboardingStep.notifications)
                        }
                    )

                case .notifications:
                    AskAllowNotificationsView(
                        allowAction: {
                            Task {
                                await NotificationAide.registerForRemoteNotifications()
                                AppPersistentMemory.shared.hasShownNotificationsOnboarding(true)
                                if FeatureFlag.isEnabled(.episodeNotifications) {
                                    path.append(OnboardingStep.episodeNotifications)
                                } else {
                                    dismiss()
                                }
                            }
                        },
                        dontAllowAction: {
                            AppPersistentMemory.shared.hasShownNotificationsOnboarding(true)
                            dismiss()
                        }
                    )

                case .episodeNotifications:
                    AskEpisodeNotificationsView(
                        optInAction: {
                            Task {
                                _ = await EpisodeNotificationSubscriber.subscribe()
                                dismiss()
                            }
                        },
                        skipAction: {
                            dismiss()
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Subviews

extension OnboardingView {

    struct WelcomeView: View {

        let advanceAction: () -> Void

        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            VStack(spacing: 0) {
                GeometryReader { geo in
                    ZStack {
                        LinearGradient(
                            colors: [Color.darkerGreen, Color.brightGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )

                        VStack(spacing: 20) {
                            Image("IconePadrao")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)

                            Text("Medo e Delírio")
                                .font(.system(size: 36, weight: .bold, design: .default))
                                .foregroundStyle(.white)

                            Text("em Brasília")
                                .font(.system(size: 22, weight: .medium, design: .default))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .padding(.top, geo.safeAreaInsets.top + 30)
                    }
                    .frame(width: geo.size.width, height: geo.size.height * 0.55)
                    .clipped()
                }
                .frame(maxHeight: .infinity)
                .ignoresSafeArea(edges: .top)

                VStack(spacing: 16) {
                    Text("Sons, músicas e muito mais do seu podcast favorito.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 30)
                        .padding(.top, 30)

                    Spacer()
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    GlassButton(
                        title: "Vamos lá",
                        color: .green,
                        fullWidth: true,
                        action: advanceAction
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                .background(Color.systemBackground)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    struct AskAllowNotificationsView: View {

        let allowAction: () -> Void
        let dontAllowAction: () -> Void

        var body: some View {
            ScrollView {
                VStack(alignment: .center) {
                    NotificationsSymbol()

                    Text("Saiba das Novidades Assim que Elas Chegam")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical)

                    Text("Receba notificações sobre os últimos sons, tendências e novos recursos.\n\nA frequência das notificações será baixa, no máximo 2 por semana.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical)
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .center, spacing: 18) {
                    GlassButton(
                        title: "Permitir notificações",
                        color: .green,
                        fullWidth: true,
                        action: allowAction
                    )

                    GlassButton(
                        title: "Ah é, é? F***-se",
                        color: .clear,
                        fullWidth: true,
                        action: dontAllowAction
                    )

                    Text("Você pode ativar as notificações mais tarde nas Configurações do app.")
                        .multilineTextAlignment(.center)
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                .background(Color.systemBackground)
            }
        }
    }

    struct AskShowExplicitContentView: View {

        let showAction: () -> Void
        let advanceAction: () -> Void

        var body: some View {
            ScrollView {
                VStack(alignment: .center, spacing: 40) {
                    Image(systemName: "mouth.fill")
                       .resizable()
                       .scaledToFit()
                       .frame(width: 100)
                       .foregroundStyle(Color.red)
                       .overlay(alignment: .bottomLeading) {
                           HStack {
                               Image(systemName: "exclamationmark.bubble.fill")
                                   .font(.system(size: 50))
                                   .scaleEffect(x: -1, y: 1)
                                   .foregroundStyle(Color.blue)
                                   .offset(x: -60, y: -40)

                               Image(systemName: "asterisk")
                                   .font(.system(size: 40))
                                   .foregroundStyle(Color.orange)
                                   .offset(x: 26, y: 30)
                           }
                           .overlay {
                               HStack {
                                   Text("🦎")
                                       .font(.system(size: 50))
                                       .foregroundStyle(Color.orange)
                                       .offset(x: -55, y: 50)
                                   Text("🐍")
                                       .font(.system(size: 50))
                                       .scaleEffect(x: -1, y: 1)
                                       .foregroundStyle(Color.blue)
                                       .offset(x: 45, y: -40)
                               }
                           }
                       }
                       .padding([.top, .bottom], 40)

                    Text(verbatim: "Po**a,  c*r*lho")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text("Muitos sons contém palavrões e você pode optar por vê-los ou não.")
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
            }
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .center, spacing: 18) {
                    GlassButton(
                        title: "Exibir Conteúdo Sensível",
                        color: .green,
                        fullWidth: true,
                        action: {
                            showAction()
                            advanceAction()
                        }
                    )

                    GlassButton(
                        title: "Não Exibir Conteúdo Sensível",
                        color: .clear,
                        fullWidth: true,
                        action: advanceAction
                    )

                    Text("Você pode mudar isso mais tarde nas Configurações do app.")
                        .multilineTextAlignment(.center)
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                .background(Color.systemBackground)
            }
        }
    }

    struct AskEpisodeNotificationsView: View {

        let optInAction: () -> Void
        let skipAction: () -> Void

        var body: some View {
            ScrollView {
                VStack(alignment: .center) {
                    Spacer()
                        .frame(height: 50)

                    Image(systemName: "headphones")
                        .font(.system(size: 74))
                        .foregroundStyle(Color.accentColor)
                        .padding(.bottom, 10)

                    Text("Nunca Perca um Episódio")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical)

                    Text("Receba uma notificação sempre que um novo episódio do podcast estiver disponível.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical)
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .center, spacing: 18) {
                    GlassButton(
                        title: "Quero Receber",
                        color: .green,
                        fullWidth: true,
                        action: optInAction
                    )

                    GlassButton(
                        title: "Agora não",
                        color: .clear,
                        fullWidth: true,
                        action: skipAction
                    )

                    Text("Você pode mudar isso mais tarde nas Configurações do app.")
                        .multilineTextAlignment(.center)
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                .background(Color.systemBackground)
            }
        }
    }

    struct AskDoFirstContentUpdateView: View {

        let selectionAction: (ContentDownloadChoice) -> Void

        @State private var selectedOption: ContentDownloadChoice? = nil

        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            ScrollView {
                VStack(alignment: .center, spacing: .spacing(.medium)) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 74))
                        .foregroundColor(.orange)

                    Text("Tem Conteúdos Novos Te Esperando")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, .spacing(.large))
                        .padding(.vertical)

                    Text("Novos sons e músicas são baixados sempre que você estiver online. Como deseja prosseguir?")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, .spacing(.large))

                    VStack(spacing: .spacing(.medium)) {
                        OptionBox(
                            icon: "clock.arrow.circlepath",
                            title: "Baixar Depois",
                            description: "Os sons serão baixados conforme você for usando o app. Mais rápido para começar.",
                            isSelected: selectedOption == .downloadLater
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedOption = .downloadLater
                            }
                        }

                        OptionBox(
                            icon: "arrow.down.circle.fill",
                            title: "Baixar Tudo Agora",
                            description: "Baixa todos os sons de uma vez. Aproximadamente 3 minutos e 20 MB.",
                            isSelected: selectedOption == .downloadAllNow
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedOption = .downloadAllNow
                            }
                        }
                    }
                    .padding(.horizontal, .spacing(.medium))
                    .padding(.top, .spacing(.medium))
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .center, spacing: .spacing(.medium)) {
                    Button {
                        if let selectedOption {
                            selectionAction(selectedOption)
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Continuar")
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .largeRoundedRectangleBorderedProminent(colored: .accentColor)
                    .disabled(selectedOption == nil)
                    .opacity(selectedOption == nil ? 0.5 : 1.0)

                    if !UIDevice.isiPhone {
                        Text("Caso a tela não feche automaticamente, toque fora dela (na área apagada).")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, .spacing(.small))
                .background(Color.systemBackground)
            }
            .sensoryFeedback(.selection, trigger: selectedOption)
        }
    }

    // MARK: - OptionBox Component

    struct OptionBox: View {

        let icon: String
        let title: String
        let description: String
        let isSelected: Bool

        @Environment(\.colorScheme) private var colorScheme

        private var backgroundColor: Color {
            if isSelected {
                return colorScheme == .dark
                    ? Color.accentColor.opacity(0.2)
                    : Color.accentColor.opacity(0.1)
            } else {
                return colorScheme == .dark
                    ? Color.gray.opacity(0.15)
                    : Color.gray.opacity(0.08)
            }
        }

        private var borderColor: Color {
            isSelected ? Color.accentColor : Color.gray.opacity(0.3)
        }

        private var borderWidth: CGFloat {
            isSelected ? 2.5 : 1.0
        }

        var body: some View {
            HStack(alignment: .center, spacing: .spacing(.medium)) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .frame(width: 44)

                VStack(alignment: .leading, spacing: .spacing(.xxxSmall)) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.spacing(.medium))
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .contentShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

// MARK: - Previews

#Preview("Full Onboarding") {
    struct SheetHost: View {
        @State private var isPresented = true

        var body: some View {
            Color.clear
                .sheet(isPresented: $isPresented) {
                    OnboardingView()
                }
        }
    }

    return SheetHost()
}

#Preview("Welcome") {
    OnboardingView.WelcomeView(advanceAction: {})
}

#Preview("Explicit Content") {
    OnboardingView.AskShowExplicitContentView(
        showAction: {},
        advanceAction: {}
    )
}

#Preview("Notifications") {
    OnboardingView.AskAllowNotificationsView(
        allowAction: {},
        dontAllowAction: {}
    )
}

#Preview("Episode Notifications") {
    OnboardingView.AskEpisodeNotificationsView(
        optInAction: {},
        skipAction: {}
    )
}

#Preview("First Update - Disabled") {
    NavigationStack {
        OnboardingView.AskDoFirstContentUpdateView(
            selectionAction: { choice in
                print("Selected: \(choice)")
            }
        )
    }
}

#Preview("Option Box - Not Selected") {
    OnboardingView.OptionBox(
        icon: "clock.arrow.circlepath",
        title: "Baixar Depois",
        description: "Os sons serão baixados conforme você for usando o app.",
        isSelected: false
    )
    .padding()
}

#Preview("Option Box - Selected") {
    OnboardingView.OptionBox(
        icon: "arrow.down.circle.fill",
        title: "Baixar Tudo Agora",
        description: "Baixa todos os sons de uma vez. Aproximadamente 3 minutos e 20 MB.",
        isSelected: true
    )
    .padding()
}
