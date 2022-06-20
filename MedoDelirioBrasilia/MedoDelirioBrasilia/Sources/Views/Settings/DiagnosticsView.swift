import SwiftUI

struct DiagnosticsView: View {

    @State var showAlert = false
    @State var alertTitle = ""
    @State var installId = UIDevice.current.identifierForVendor?.uuidString ?? ""
    @State var shareLogs: [UserShareLog]?
    @State var networkLogs: [NetworkCallLog]?
    
    var body: some View {
        Form {
            Section {
                Button("Testar conexão com o servidor") {
                    networkRabbit.checkServerStatus { _, response in
                        alertTitle = response
                        showAlert = true
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(alertTitle), dismissButton: .default(Text("OK")))
                }
            }
            
            Section {
                Text(installId)
                    .font(.monospaced(.subheadline)())
                    .onTapGesture {
                        UIPasteboard.general.string = installId
                    }
            } header: {
                Text("ID da instalação")
            } footer: {
                Text("Esse código identifica apenas a instalação do app e é renovado caso você o desinstale e instale novamente.")
            }
            
            if CommandLine.arguments.contains("-UNDER_DEVELOPMENT") {
                Section("Tendências [DEV ONLY]") {
                    Button("Setar dia de envio para ontem") {
                        var dayComponent = DateComponents()
                        dayComponent.day = -1
                        let calendar = Calendar.current
                        let newDate = calendar.date(byAdding: dayComponent, to: Date())
                        UserSettings.setLastSendDateOfUserPersonalTrendsToServer(to: newDate!.onlyDate!)
                    }
                }
            }
            
            Section("Logs de compartilhamento") {
                if shareLogs == nil || shareLogs?.count == 0 {
                    Text("Sem Dados")
                } else {
                    List(shareLogs!) { log in
                        SharingLogCell(destination: ShareDestination(rawValue: log.destination) ?? .other, contentType: ContentType(rawValue: log.contentType) ?? .sound, contentTitle: getContentName(contentId: log.contentId), dateTime: log.dateTime.toString(), sentToServer: log.sentToServer)
                    }
                }
            }
            
            Section("Logs de rede") {
                if networkLogs == nil || networkLogs?.count == 0 {
                    Text("Sem Dados")
                } else {
                    List(networkLogs!) { log in
                        NetworkLogCell(callType: NetworkCallType(rawValue: log.callType) ?? .checkServerStatus, dateTime: log.dateTime.toString(), wasSuccessful: log.wasSuccessful)
                    }
                }
            }
        }
        .navigationTitle("Diagnóstico")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            shareLogs = try? database.getAllUserShareLogs()
            shareLogs?.sort(by: { $0.dateTime > $1.dateTime })
            networkLogs = try? database.getAllNetworkCallLogs()
            networkLogs?.sort(by: { $0.dateTime > $1.dateTime })
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
