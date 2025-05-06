import SwiftUI

struct FirstOnboardingView: View {

    @Binding var isBeingShown: Bool
    @State private var showWhatsNew: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center) {
                    NavigationLink(destination: ShowExplicitContentOnboardingView(isBeingShown: $isBeingShown), isActive: $showWhatsNew) { EmptyView() }

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
                        Task {
                            await NotificationAide.registerForRemoteNotifications()
                            AppPersistentMemory().hasShownNotificationsOnboarding(true)
                            showWhatsNew = true
                        }
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
                        AppPersistentMemory().hasShownNotificationsOnboarding(true)
                        showWhatsNew = true
                    } label: {
                        Text("Ah é, é? F***-se")
                    }
                    .foregroundColor(.blue)

                    if UIDevice.current.userInterfaceIdiom != .phone {
                        Text("Caso a tela não feche automaticamente ao escolher uma das opções, toque fora dela (na área apagada).")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .font(.callout)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }

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
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        FirstOnboardingView(isBeingShown: .constant(true))
    }
}
