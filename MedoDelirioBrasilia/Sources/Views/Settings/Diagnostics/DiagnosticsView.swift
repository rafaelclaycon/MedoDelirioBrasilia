//
//  DiagnosticsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 03/06/22.
//

import SwiftUI
import Kingfisher

struct DiagnosticsView: View {

    let database: LocalDatabaseProtocol
    let analyticsService: AnalyticsServiceProtocol

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

            ImportFavoritesView(database: database, analyticsService: analyticsService)

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

        let database: LocalDatabaseProtocol
        let analyticsService: AnalyticsServiceProtocol

        struct ImportResult {

            let importCount: Int
            let errorMessage: String?
        }

        @State private var displayPicker: Bool = false

        @State private var displayError: Bool = false
        @State private var displaySuccessAlert: Bool = false

        @State private var importCount: Int = 0
        @State private var errorMessage: String = ""

        var body: some View {
            Section {
                Button("Selecionar arquivo CSV") {
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
                        Task {
                            await process(fileUrl)
                        }

                    case .failure(let failure):
                        errorMessage = failure.localizedDescription
                        displayError.toggle()
                    }
                }
                .alert(
                    "\(importCount) Favoritos Importados com Sucesso",
                    isPresented: $displaySuccessAlert
                ) {
                    Button("OK") {
                        displaySuccessAlert.toggle()
                    }
                }
                .alert(
                    "Erro ao Tentar Importar Favoritos: \(errorMessage)",
                    isPresented: $displayError
                ) {
                    Button("OK") {
                        displayError.toggle()
                    }
                }
            } header: {
                Text("Importar favoritos de um arquivo")
            } footer: {
                Text("Para que essa opção funcione, selecione um arquivo que contém apenas os IDs dos conteúdos, cada um em uma linha, e nada mais, em um arquivo no formato .csv.")
            }
        }

        private func process(_ fileUrl: URL) async {
            if let ids = await parseFile(at: fileUrl) {
                let result = addToFavorites(ids: ids)
                guard let error = result.errorMessage else {
                    importCount = result.importCount
                    displaySuccessAlert.toggle()
                    await logSuccess(result.importCount)
                    return
                }
                errorMessage = error
                displayError.toggle()
                await logError(error)
            } else {
                errorMessage = "Arquivo Inacessível ou Outro Erro ao Tentar Obter IDs"
                displayError.toggle()
                await logError(errorMessage)
            }
        }

        private func logError(_ message: String) async {
            await analyticsService.send(
                originatingScreen: "DiagnosticsView",
                action: "hadIssueImportingFavorites(\(message))"
            )
        }

        private func logSuccess(_ count: Int) async {
            await analyticsService.send(
                originatingScreen: "DiagnosticsView",
                action: "importedFavorites(\(count))"
            )
        }

        private func parseFile(at fileUrl: URL) async -> [String]? {
            let didStartAccessing = fileUrl.startAccessingSecurityScopedResource()
            defer {
                if didStartAccessing {
                    fileUrl.stopAccessingSecurityScopedResource()
                }
            }
            guard FileManager.default.fileExists(atPath: fileUrl.path) else { return nil }

            do {
                let (data, _) = try await URLSession.shared.data(from: fileUrl)
                if let content = String(data: data, encoding: .utf8) {
                    return content.components(separatedBy: .newlines)
                } else {
                    return nil
                }
            } catch {
                print("Error fetching file: \(error)")
                return nil
            }

        }

        private func addToFavorites(ids contentIds: [String]) -> ImportResult {
            guard !contentIds.isEmpty else { return ImportResult(importCount: 0, errorMessage: "O vetor de IDs está vazio.") }

            do {
                var counter: Int = 0
                try contentIds.forEach { id in
                    guard try database.contentExists(withId: id) else { return }
                    guard try !database.isFavorite(contentId: id) else { return }
                    try database.insert(favorite: Favorite(contentId: id, dateAdded: .now))
                    print("Successfully imported \(id)")
                    counter += 1
                }
                return ImportResult(importCount: counter, errorMessage: nil)
            } catch {
                return ImportResult(importCount: 0, errorMessage: error.localizedDescription)
            }
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
//    DiagnosticsView(
//        database: FakeLocalDatabase(),
//        analyticsService: FakeAnalyticsService()
//    )
}
