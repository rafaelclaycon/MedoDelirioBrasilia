import SwiftUI

struct OnboardingView: View {

    @Binding var isBeingShown: Bool
    
    @State var enrollOnGeneralChannel = false
    @State var enrollOnNewEpisodesChannel = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                NotificationsSymbol()
                
                Text("Apresentando os Canais")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical)
                
                Text("Agora, além de receber as notificações de sempre, você pode (opcionalmente) ser notificado de novos episódios do podcast assim que eles saírem.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical)
                
                HStack {
                    Text("CANAIS")
                        .font(.footnote)
                        .bold()
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.leading, 34)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 140)
                    
                    VStack(spacing: 15) {
                        Toggle("Geral (novos sons, tendências, novos recursos)", isOn: $enrollOnGeneralChannel)
                        //                    .onChange(of: enableNotifications) { newValue in
                        //                        if newValue == true {
                        //                            NotificationAide.registerForRemoteNotifications() { _ in
                        //                                enableNotifications = UserSettings.getUserAllowedNotifications()
                        //                            }
                        //                        } else {
                        //                            UserSettings.setUserAllowedNotifications(to: newValue)
                        //                        }
                        //                    }
                        
                        Divider()
                        
                        Toggle("Novos Episódios (Beta)", isOn: $enrollOnNewEpisodesChannel)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                .padding(.top, -7)
                
                Button {
                    NotificationAide.registerForRemoteNotifications() { _ in
                        AppPersistentMemory.setHasShownNotificationsOnboarding(to: true)
                        isBeingShown = false
                    }
                } label: {
                    Text("Parece bom, ir para o app")
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 50)
                }
                .tint(.accentColor)
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .padding(.vertical)
                
//                Button {
//                    AppPersistentMemory.setHasShownNotificationsOnboarding(to: true)
//                    isBeingShown = false
//                } label: {
//                    Text("Ah é, é? F***-se")
//                }
//                .foregroundColor(.blue)
//                .padding(.vertical)
                
                if UIDevice.current.userInterfaceIdiom != .phone {
                    Text("Caso a tela não feche automaticamente ao escolher uma das opções, toque fora dela (na área apagada).")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .font(.callout)
                        .foregroundColor(.gray)
                        .padding(.vertical)
                        .padding(.horizontal)
                }
                
                Text("Você pode ativar ou desativar os canais mais tarde nos Ajustes do app.")
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
