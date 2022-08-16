import SwiftUI

struct DiagnosticsView: View {

    @State var showServerConnectionTestAlert = false
    @State var serverConnectionTestAlertTitle = ""
    
    @State var installId = UIDevice.current.identifierForVendor?.uuidString ?? ""
    @State var showInstallIdCopiedAlert = false
    
    @State var showFavoriteDiagnosticsAlert = false
    @State var favoriteDiagnosticsAlertTitle = ""
    @State var favoriteDiagnosticsAlertMessage = ""
    
    @State var shareLogs: [UserShareLog]?
    //@State var networkLogs: [NetworkCallLog]?
    
    var body: some View {
        Form {
            Section {
                Button("Testar conexão com o servidor") {
                    networkRabbit.checkServerStatus { _, response in
                        serverConnectionTestAlertTitle = response
                        showServerConnectionTestAlert = true
                    }
                }
                .alert(isPresented: $showServerConnectionTestAlert) {
                    Alert(title: Text(serverConnectionTestAlertTitle), dismissButton: .default(Text("OK")))
                }
            }
            
            Section {
                Text(installId)
                    .font(.monospaced(.subheadline)())
                    .onTapGesture {
                        UIPasteboard.general.string = installId
                        showInstallIdCopiedAlert = true
                    }
                    .alert(isPresented: $showInstallIdCopiedAlert) {
                        Alert(title: Text("ID copiado com sucesso!"), dismissButton: .default(Text("OK")))
                    }
            } header: {
                Text("ID da instalação")
            } footer: {
                Text("Esse código identifica apenas a instalação do app e é renovado caso você o desinstale e instale novamente.")
            }
            
            Section {
                Button("Ver Favoritos internos") {
                    guard let favorites = try? database.getAllFavorites() else {
                        favoriteDiagnosticsAlertTitle = "Não Foi Possível Obter a Quantidade de Favoritos"
                        favoriteDiagnosticsAlertMessage = "Informe o desenvolvedor."
                        return showFavoriteDiagnosticsAlert = true
                    }
                    favoriteDiagnosticsAlertTitle = "\(favorites.count) Favorito(s) Cadastrados"
                    favoriteDiagnosticsAlertMessage = ""
                    for (index, favorite) in favorites.enumerated() {
                        if let sound = soundData.first(where: {$0.id == favorite.contentId}) {
                            favoriteDiagnosticsAlertMessage = favoriteDiagnosticsAlertMessage + "\(sound.title) \(favorite.dateAdded.toString())"
                        } else {
                            favoriteDiagnosticsAlertMessage = favoriteDiagnosticsAlertMessage + "Som não identificado"
                        }
                        if index != (favorites.count - 1) {
                            favoriteDiagnosticsAlertMessage = favoriteDiagnosticsAlertMessage + ";\n"
                        }
                    }
                    showFavoriteDiagnosticsAlert = true
                }
                .alert(isPresented: $showFavoriteDiagnosticsAlert) {
                    Alert(title: Text(favoriteDiagnosticsAlertTitle), message: Text(favoriteDiagnosticsAlertMessage), dismissButton: .default(Text("OK")))
                }
            }
            
            /*if CommandLine.arguments.contains("-UNDER_DEVELOPMENT") {
                Section("Tendências [DEV ONLY]") {
                    Button("Setar dia de envio para ontem") {
                        var dayComponent = DateComponents()
                        dayComponent.day = -1
                        let calendar = Calendar.current
                        let newDate = calendar.date(byAdding: dayComponent, to: Date())
                        UserSettings.setLastSendDateOfUserPersonalTrendsToServer(to: newDate!.onlyDate!)
                    }
                }
            }*/
            
            Section("Logs de compartilhamento") {
                if shareLogs == nil || shareLogs?.count == 0 {
                    Text("Sem Dados")
                } else {
                    List(shareLogs!) { log in
                        SharingLogCell(destination: ShareDestination(rawValue: log.destination) ?? .other, contentType: ContentType(rawValue: log.contentType) ?? .sound, contentTitle: getContentName(contentId: log.contentId), dateTime: log.dateTime.toString(), sentToServer: log.sentToServer)
                    }
                }
            }
            
            /*Section("Logs de rede") {
                if networkLogs == nil || networkLogs?.count == 0 {
                    Text("Sem Dados")
                } else {
                    List(networkLogs!) { log in
                        NetworkLogCell(callType: NetworkCallType(rawValue: log.callType) ?? .checkServerStatus, dateTime: log.dateTime.toString(), wasSuccessful: log.wasSuccessful)
                    }
                }
            }*/
        }
        .navigationTitle("Diagnóstico")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            shareLogs = try? database.getAllUserShareLogs()
            shareLogs?.sort(by: { $0.dateTime > $1.dateTime })
            /*networkLogs = try? database.getAllNetworkCallLogs()
            networkLogs?.sort(by: { $0.dateTime > $1.dateTime })*/
        }
    }
    
    func getContentName(contentId: String) -> String {
        let sounds = soundData.filter({ $0.id == contentId })
        let songs = songData.filter({ $0.id == contentId })
        var contentTitle = ""
        if sounds.count == 1 {
            contentTitle = sounds.first!.title
        } else if songs.count == 1 {
            contentTitle = songs.first!.title
        }
        return contentTitle
    }

}

struct DiagnosticsView_Previews: PreviewProvider {

    static var previews: some View {
        DiagnosticsView()
    }

}
