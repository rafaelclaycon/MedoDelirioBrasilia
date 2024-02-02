//
//  DiagnosticsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 03/06/22.
//

import SwiftUI

struct DiagnosticsView: View {

    @State var showServerConnectionTestAlert = false
    @State var serverConnectionTestAlertTitle = ""
    
    @State var installId = UIDevice.customInstallId
    @State var showInstallIdCopiedAlert = false

    @State private var showUpdateDateOnUI: Bool = UserSettings.getShowUpdateDateOnUI()

    @State var shareLogs: [UserShareLog]?
    //@State var networkLogs: [NetworkCallLog]?
    
    var body: some View {
        Form {
            Section {
                Button("Testar conexão com o servidor") {
                    Task {
                        let serverIsAvailable = await NetworkRabbit.shared.serverIsAvailable()
                        serverConnectionTestAlertTitle = serverIsAvailable ? "A conexão com o servidor está OK." : "Erro ao tentar contatar o servidor; é possível que ele esteja fora para manutenção temporária. Se o erro persistir, use o botão Entrar Em Contato Por E-mail na tela anterior."
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
                Text("Esse código identifica apenas a instalação do app e é renovado caso você o desinstale e instale novamente. Toque nele uma vez para copiar.")
            }

            if #available(iOS 16.0, *) {
                Section {
                    ShareLink(
                        item: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("medo_db.sqlite3")
                    ) {
                        Text("Exportar base de dados")
                    }
                }
            }

            Section {
                Toggle("Exibir data e hora da última atualização na UI", isOn: $showUpdateDateOnUI)
                    .onChange(of: showUpdateDateOnUI) {
                        UserSettings.setShowUpdateDateOnUI(to: $0)
                    }
            }

            /*if CommandLine.arguments.contains("-UNDER_DEVELOPMENT") {
                Section("Tendências [DEV ONLY]") {
                    Button("Setar dia de envio para ontem") {
                        var dayComponent = DateComponents()
                        dayComponent.day = -1
                        let calendar = Calendar.current
                        let newDate = calendar.date(byAdding: dayComponent, to: Date())
                        AppPersistentMemory.setLastSendDateOfUserPersonalTrendsToServer(to: newDate!.onlyDate!)
                    }
                }
            }*/
            
            Section("Logs de compartilhamento") {
                if shareLogs == nil || shareLogs?.count == 0 {
                    Text("Sem Dados")
                } else {
                    List(shareLogs!) { log in
                        SharingLogCell(destination: ShareDestination(rawValue: log.destination) ?? .other, contentType: ContentType(rawValue: log.contentType) ?? .sound, contentTitle: getContentName(contentId: log.contentId), dateTime: log.dateTime.toScreenString(), sentToServer: log.sentToServer)
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
            shareLogs = try? LocalDatabase.shared.getAllUserShareLogs()
            shareLogs?.sort(by: { $0.dateTime > $1.dateTime })
            /*networkLogs = try? database.getAllNetworkCallLogs()
            networkLogs?.sort(by: { $0.dateTime > $1.dateTime })*/
        }
    }

    func getContentName(contentId: String) -> String {
        do {
            if let sound: Sound = try LocalDatabase.shared.sound(withId: contentId) {
                return sound.title
            } else if let song: Song = try LocalDatabase.shared.song(withId: contentId) {
                return song.title
            } else {
                return ""
            }
        } catch {
            return ""
        }
    }
}

struct DiagnosticsView_Previews: PreviewProvider {
    static var previews: some View {
        DiagnosticsView()
    }
}
