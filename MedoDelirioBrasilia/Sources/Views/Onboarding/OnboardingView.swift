import SwiftUI
import UserNotifications

struct OnboardingView: View {

    @Binding var isBeingShown: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                NotificationsSymbol()
                
                Text("Saiba das Novidades Assim que Elas Chegarem")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.vertical)
                
                Text("Receba notificações sobre os últimos sons, tendências e novos recursos.\n\nTentaremos manter a frequência das notificações baixa, entre 2 e 3 por semana.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical)
                
                Button {
                    registerForRemoteNotifications()
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
                    isBeingShown = false
                } label: {
                    Text("Ah é, é? F***-se")
                        .bold()
                }
                .foregroundColor(.blue)
                .padding(.vertical)
                
                Text("Você pode ativar as notificações mais tarde nos Ajustes.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            .padding(.top, 100)
            .padding(.bottom, 100)
        }
    }
    
    private func registerForRemoteNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.sound, .alert]) { granted, error in
            if error == nil {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            isBeingShown = false
        }
    }

}

struct OnboardingView_Previews: PreviewProvider {

    static var previews: some View {
        OnboardingView(isBeingShown: .constant(true))
    }

}
