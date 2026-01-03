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

struct OnboardingView: View {

    // NOTE: Content Download Choice feature is disabled for now.
    // The selectionAction and AskDoFirstContentUpdateView are preserved for future use.
    // var selectionAction: ((ContentDownloadChoice) -> Void)? = nil

    @State private var showAskShowSensitive: Bool = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            AskAllowNotificationsView(
                allowAction: {
                    Task {
                        await NotificationAide.registerForRemoteNotifications()
                        AppPersistentMemory.shared.hasShownNotificationsOnboarding(true)
                        showAskShowSensitive = true
                    }
                },
                dontAllowAction: {
                    AppPersistentMemory.shared.hasShownNotificationsOnboarding(true)
                    showAskShowSensitive = true
                }
            )
            .navigationDestination(isPresented: $showAskShowSensitive) {
                AskShowExplicitContentView(
                    showAction: {
                        UserSettings().setShowExplicitContent(to: true)
                    },
                    completionAction: { dismiss() }
                )
            }
        }
    }
}

// MARK: - Subviews

extension OnboardingView {

    struct AskAllowNotificationsView: View {

        let allowAction: () -> Void
        let dontAllowAction: () -> Void

        var body: some View {
            ScrollView {
                VStack(alignment: .center) {
                    Spacer()
                        .frame(height: 50)

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
                    Button {
                        allowAction()
                    } label: {
                        Text("Permitir notificações")
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 50)
                    }
                    .tint(.accentColor)
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)

                    Button {
                        dontAllowAction()
                    } label: {
                        Text("Ah é, é? F***-se")
                    }
                    .foregroundColor(.blue)

                    Text("Você pode ativar as notificações mais tarde nas Configurações do app.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 10)
                .background(Color.systemBackground)
            }
        }
    }

    struct AskShowExplicitContentView: View {

        let showAction: () -> Void
        let completionAction: () -> Void

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
                VStack(alignment: .center, spacing: 22) {
                    Button {
                        showAction()
                        completionAction()
                    } label: {
                        Text("Exibir Conteúdo Sensível")
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                    .tint(.accentColor)
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 15))

                    Button {
                        completionAction()
                    } label: {
                        Text("Não Exibir Conteúdo Sensível")
                    }
                    .foregroundColor(.blue)

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

#Preview {
    OnboardingView()
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
