//
//  OnboardingView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/08/22.
//

import SwiftUI

struct OnboardingView: View {

    @State private var showAskShowSensitive: Bool = false
    @State private var showAskDoFirstUpdate: Bool = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            AskAllowNotificationsView(
                allowAction: {
                    Task {
                        await NotificationAide.registerForRemoteNotifications()
                        AppPersistentMemory().hasShownNotificationsOnboarding(true)
                        showAskShowSensitive = true
                    }
                },
                dontAllowAction: {
                    AppPersistentMemory().hasShownNotificationsOnboarding(true)
                    showAskShowSensitive = true
                }
            )
            .navigationDestination(isPresented: $showAskShowSensitive) {
                AskShowExplicitContentView(
                    showAction: {
                        UserSettings().setShowExplicitContent(to: true)
                        showAskDoFirstUpdate = true
                    },
                    dontShowAction: {
                        showAskDoFirstUpdate = true
                    }
                )
            }
            .navigationDestination(isPresented: $showAskDoFirstUpdate) {
                AskDoFirstContentUpdateView(
                    allowAction: {
                        
                    },
                    dontAllowAction: { dismiss() }
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
        let dontShowAction: () -> Void

        @Environment(\.dismiss) private var dismiss

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
                        dontShowAction()
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

        let allowAction: () -> Void
        let dontAllowAction: () -> Void

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
                        .padding(.horizontal, 20)
                        .padding(.vertical)

                    VStack(alignment: .center, spacing: .spacing(.xLarge)) {
                        Text("Novos sons e músicas são baixados sempre que você estiver online. Como é a primeira vez que você abre o app, a primeira atualização é a mais longa:")
                            .multilineTextAlignment(.center)

                        Text("Aproximadamente 3 minutos - 20 MB")
                            .multilineTextAlignment(.center)
                            .bold()

                        Text("Deseja realizá-la agora?")
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, .spacing(.large))
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .center, spacing: .spacing(.xLarge)) {
                    Button {
                        allowAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Atualizar agora")
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .largeRoundedRectangleBorderedProminent(colored: .accentColor)

                    Button {
                        dontAllowAction()
                    } label: {
                        Text("Perguntar depois")
                    }
                    .foregroundColor(.blue)

                    if !UIDevice.isiPhone {
                        Text("Caso a tela não feche automaticamente ao escolher uma das opções, toque fora dela (na área apagada).")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .font(.callout)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                .background(Color.systemBackground)
            }
        }
    }
}

// MARK: - Previews

#Preview {
    OnboardingView()
}

#Preview("First Update") {
    NavigationStack {
        OnboardingView.AskDoFirstContentUpdateView(
            allowAction: {},
            dontAllowAction: {}
        )
    }
}
