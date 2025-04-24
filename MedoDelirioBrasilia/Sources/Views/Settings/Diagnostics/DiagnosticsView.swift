//
//  DiagnosticsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 03/06/22.
//

import SwiftUI
import Kingfisher

struct DiagnosticsView: View {

    @State private var showUpdateDateOnUI: Bool = UserSettings().getShowUpdateDateOnUI()



    var body: some View {
        Form {
            TestServerConnectionView()

            InstallIdView()

            ImageCacheOptionsView()

            Section {
                ShareLink(
                    item: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("medo_db.sqlite3")
                ) {
                    Text("Exportar base de dados")
                }
            }

            ImportFavoritesView()

            Section {
                Toggle("Exibir data e hora da última atualização na UI", isOn: $showUpdateDateOnUI)
                    .onChange(of: showUpdateDateOnUI) {
                        UserSettings().setShowUpdateDateOnUI(to: showUpdateDateOnUI)
                    }
            }
            
            ShareLogsView()
        }
        .navigationTitle("Diagnóstico")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension DiagnosticsView {

    struct TestServerConnectionView: View {

        @State private var showServerConnectionTestAlert = false
        @State private var serverConnectionTestAlertTitle = ""

        var body: some View {
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
        }
    }

    struct InstallIdView: View {

        @State private var installId = AppPersistentMemory().customInstallId
        @State private var showInstallIdCopiedAlert = false

        var body: some View {
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
        }
    }

    struct ImageCacheOptionsView: View {

        @State private var diskImageCacheText: String = ""
        @State private var cleanImageCacheAlert: Bool = false

        var body: some View {
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
            .onAppear {
                updateImageCacheSizeText()
            }
        }

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
    }

    struct ImportFavoritesView: View {

        @State private var displayPicker: Bool = false
        @State private var displayError: Bool = false
        @State private var errorMessage: String = ""

        var body: some View {
            Section {
                Button("Importar favoritos de um arquivo CSV") {
                    displayPicker.toggle()
                }
                .fileImporter(
                    isPresented: $displayPicker,
                    allowedContentTypes: [.commaSeparatedText],
                    allowsMultipleSelection: false)
                { result in
                    switch result {
                    case .success(let success):
                        guard let fileUrl = success.items.first else { return }
                        parseFile(at: fileUrl)

                    case .failure(let failure):
                        errorMessage = failure.localizedDescription
                        displayError.toggle()
                    }
                }
                .alert(
                    "Erro ao Tentar Importar Favoritos: \(errorMessage)",
                    isPresented: $displayError) {
                        Button("OK") {
                            displayError.toggle()
                        }
                    }
            } footer: {
                Text("Para que essa opção funcione, selecione um arquivo que contém apenas os IDs dos conteúdos, cada um em uma linha, e nada mais, em um arquivo no formato .csv.")
            }
        }

        private func parseFile(at fileUrl: URL) {
            let task = URLSession.shared.dataTask(with: fileUrl) { data, response, error in
                if let data = data, let content = String(data: data, encoding: .utf8) {
                    let lines = content.components(separatedBy: .newlines)
                    for line in lines {
                        print(line)
                    }
                } else if let error = error {
                    print("Error fetching file: \(error)")
                }
            }
            task.resume()
        }
    }

    struct ShareLogsView: View {

        @State private var shareLogs: [UserShareLog]?

        var body: some View {
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
            .onAppear {
                shareLogs = try? LocalDatabase.shared.getAllUserShareLogs()
                shareLogs?.sort(by: { $0.dateTime > $1.dateTime })
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
}

#Preview {
    DiagnosticsView()
}
