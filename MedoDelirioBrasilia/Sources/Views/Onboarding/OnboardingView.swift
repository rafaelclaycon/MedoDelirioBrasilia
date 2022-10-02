import SwiftUI

struct OnboardingView: View {

    @Binding var isBeingShown: Bool
    
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
                
                Button {
                    NotificationAide.registerForRemoteNotifications() { _ in
                        AppPersistentMemory.setHasShownNotificationsOnboarding(to: true)
                        isBeingShown = false
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
                .padding(.top)
                
                Button {
                    AppPersistentMemory.setHasShownNotificationsOnboarding(to: true)
                    isBeingShown = false
                } label: {
                    Text("Ah é, é? F***-se")
                }
                .foregroundColor(.blue)
                .padding(.vertical)
                
                Text("Você pode ativar as notificações mais tarde nos Ajustes do app.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            .padding(.top, 100)
            .padding(.bottom, 100)
        }
    }

}

struct OnboardingView_Previews: PreviewProvider {

    static var previews: some View {
        OnboardingView(isBeingShown: .constant(true))
    }

}
