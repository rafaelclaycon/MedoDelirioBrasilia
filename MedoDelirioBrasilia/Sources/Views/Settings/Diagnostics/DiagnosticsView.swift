//
//  DiagnosticsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 03/06/22.
//

import SwiftUI
import Kingfisher

struct DiagnosticsView: View {

    @State private var showServerConnectionTestAlert = false
    @State private var serverConnectionTestAlertTitle = ""

    @State private var installId = AppPersistentMemory().customInstallId
    @State private var showInstallIdCopiedAlert = false

    @State private var diskImageCacheText: String = ""
    @State private var cleanImageCacheAlert: Bool = false

    @State private var showUpdateDateOnUI: Bool = UserSettings().getShowUpdateDateOnUI()

    @State private var shareLogs: [UserShareLog]?
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

            Section("Cache de imagens") {
                Text(diskImageCacheText)

                Button("Limpar cache") {
                    Task {
                        ImageCache.default.clearMemoryCache()
                        ImageCache.default.clearDiskCache {
                            updateImageCacheSizeText()
                            cleanImageCacheAlert = true
                        }
                    }
                }
                .alert(isPresented: $cleanImageCacheAlert) {
                    Alert(title: Text("Cache de imagens limpado com sucesso"), dismissButton: .default(Text("OK")))
                }
            }

            Section {
                ShareLink(
                    item: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("medo_db.sqlite3")
                ) {
                    Text("Exportar base de dados")
                }
            }

            Section {
                Toggle("Exibir data e hora da última atualização na UI", isOn: $showUpdateDateOnUI)
                    .onChange(of: showUpdateDateOnUI) {
                        UserSettings().setShowUpdateDateOnUI(to: $0)
                    }
            }

            /*if CommandLine.arguments.contains("-SHOW_MORE_DEV_OPTIONS") {
                Section("Tendências [DEV ONLY]") {
                    Button("Setar dia de envio para ontem") {
                        var dayComponent = DateComponents()
                        dayComponent.day = -1
                        let calendar = Calendar.current
                        let newDate = calendar.date(byAdding: dayComponent, to: Date())
                        AppPersistentMemory().setLastSendDateOfUserPersonalTrendsToServer(to: newDate!.onlyDate!)
                    }
                }
            }*/
            
            Section("Logs de compartilhamento") {
                if shareLogs == nil || shareLogs?.count == 0 {
                    Text("Sem Dados")
                } else {
                    List(shareLogs!) { log in
                        SharingLogCell(
                            destination: ShareDestination(rawValue: log.destination) ?? .other,
                            contentType: ContentType(rawValue: log.contentType) ?? .sound,
                            contentTitle: getContentName(contentId: log.contentId),
                            dateTime: log.dateTime.formattedDayMonthYearHoursMinutesSeconds(),
                            sentToServer: log.sentToServer
                        )
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
            updateImageCacheSizeText()

            shareLogs = try? LocalDatabase.shared.getAllUserShareLogs()
            shareLogs?.sort(by: { $0.dateTime > $1.dateTime })
            /*networkLogs = try? database.getAllNetworkCallLogs()
            networkLogs?.sort(by: { $0.dateTime > $1.dateTime })*/
        }
    }

    // MARK: - Functions

    private func updateImageCacheSizeText() {
        ImageCache.default.calculateDiskStorageSize { result in
            switch result {
            case .success(let size):
                let imageCacheSize = Double(size) / 1024 / 1024
                diskImageCacheText = "Tamanho: \(imageCacheSize.formatted(.number.precision(.fractionLength(1)))) MB"
            case .failure(let error):
                diskImageCacheText = error.localizedDescription
            }
        }
    }

    private func getContentName(contentId: String) -> String {
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
