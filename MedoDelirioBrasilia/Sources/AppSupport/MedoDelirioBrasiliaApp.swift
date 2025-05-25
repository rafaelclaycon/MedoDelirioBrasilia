//
//  MedoDelirioBrasiliaApp.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 05/05/22.
//

import SwiftUI

var moveDatabaseIssue: String = ""

@main
struct MedoDelirioBrasiliaApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var tabSelection: PhoneTab = .sounds
    @State private var state: PadScreen? = PadScreen.allSounds

    @State private var helper = PlayRandomSoundHelper()

    var body: some Scene {
        WindowGroup {
            MainView(tabSelection: $tabSelection, padSelection: $state)
                .onOpenURL(perform: handleURL)
                .environment(helper)
        }
    }

    private func handleURL(_ url: URL) {
        guard url.scheme == "medodelirio" else { return }
        if url.host == "playrandomsound" {
            tabSelection = .sounds

            let includeOffensive = UserSettings().getShowExplicitContent()

            do {
                guard
                    let randomSound = try LocalDatabase.shared.randomSound(includeOffensive: includeOffensive)
                else { return }
                helper.soundIdToPlay = randomSound.id
                Task {
                    await AnalyticsService().send(action: "didPlayRandomSound(\(randomSound.title))")
                }
            } catch {
                print("Erro obtendo som aleatório: \(error.localizedDescription)")
                Task {
                    await AnalyticsService().send(action: "hadErrorPlayingRandomSound(\(error.localizedDescription))")
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    @AppStorage("hasMigratedSoundsAuthors") private var hasMigratedSoundsAuthors = false
    @AppStorage("hasMigratedSongsMusicGenres") private var hasMigratedSongsMusicGenres = false
    @AppStorage("hasUpdatedExternalLinksOnFirstRun") private var hasUpdatedExternalLinksOnFirstRun = false
    @AppStorage("hasUpdatedFolderHashesOnFirstRun") private var hasUpdatedFolderHashesOnFirstRun = false

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        print("APP - APP DELEGATE")
        // Fixes
        moveDatabaseFileIfNeeded()
        replaceUserSettingFlag()
        
        do {
            try LocalDatabase.shared.migrateIfNeeded()
        } catch {
            fatalError("Failed to migrate database: \(error)")
        }
        
        //print(database)
        
        if !hasMigratedSoundsAuthors {
            moveSoundsAndAuthorsToDatabase()
            hasMigratedSoundsAuthors = true
        }

        if !hasMigratedSongsMusicGenres {
            moveSongsAndMusicGenresToDatabase()
            hasMigratedSongsMusicGenres = true
        }
        
        prepareAudioPlayerOnMac()
        Task {
            await collectTelemetry()
        }
        createFoldersForDownloadedContent()
        updateExternalLinks()
        updateFolderChangeHashes()

        return true
    }

    // This fixes the issue in which a sound would take 10 seconds to play on the Mac
    private func prepareAudioPlayerOnMac() {
        guard ProcessInfo.processInfo.isiOSAppOnMac else { return }
        guard let path = Bundle.main.path(forResource: "Lula - Eu posso tomar cafe.mp3", ofType: nil) else { return }
        let url = URL(fileURLWithPath: path)
        AudioPlayer.shared = AudioPlayer(url: url, update: { _ in })
        AudioPlayer.shared?.prepareToPlay()
    }
    
    // MARK: - Telemetry

    private func collectTelemetry() async {
        await sendDeviceModelNameToServer()
        await sendStillAliveSignalToServer()
    }

    private func sendDeviceModelNameToServer() async {
        guard AppPersistentMemory.shared.getHasSentDeviceModelToServer() == false else {
            return
        }
        let info = ClientDeviceInfo(installId: AppPersistentMemory.shared.customInstallId, modelName: UIDevice.modelName)
        do {
            try await APIClient.shared.post(clientDeviceInfo: info)
            AppPersistentMemory.shared.setHasSentDeviceModelToServer(to: true)
        } catch {
            print("Erro enviando device model para o servidor:")
            debugPrint(error)
        }
    }

    private func sendStillAliveSignalToServer() async {
        let lastDate = UserSettings().getLastSendDateOfStillAliveSignalToServer()

        // Should only send 1 still alive signal per day
        guard lastDate == nil || lastDate!.onlyDate! < Date.now.onlyDate! else {
            return
        }

        let signal = StillAliveSignal(
            installId: AppPersistentMemory.shared.customInstallId,
            modelName: UIDevice.modelName,
            systemName: UIDevice.current.systemName,
            systemVersion: UIDevice.current.systemVersion,
            isiOSAppOnMac: ProcessInfo.processInfo.isiOSAppOnMac,
            appVersion: Versioneer.appVersion,
            currentTimeZone: TimeZone.current.abbreviation() ?? "",
            dateTime: Date.now.iso8601withFractionalSeconds
        )

        do {
            let url = URL(string: APIClient.shared.serverPath + "v1/still-alive-signal")!
            try await APIClient.shared.post(to: url, body: signal)
            UserSettings().setLastSendDateOfStillAliveSignalToServer(to: Date.now)
        } catch {
            debugPrint(error)
        }
    }

    // MARK: - Push notifications
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task {
            if AppPersistentMemory.shared.getShouldRetrySendingDevicePushToken() {
                let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
                let token = tokenParts.joined()
                //print("Device Token: \(token)")

                let device = PushDevice(installId: AppPersistentMemory.shared.customInstallId, pushToken: token)

                do {
                    let success = try await APIClient.shared.register(pushDevice: device)
                    AppPersistentMemory.shared.setShouldRetrySendingDevicePushToken(to: !success)
                } catch {
                    AppPersistentMemory.shared.setShouldRetrySendingDevicePushToken(to: true)
                }
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register: \(error.localizedDescription)")
    }
    
    // MARK: - Missing Favorites bugfix
    
    private func moveDatabaseFileIfNeeded() {
        guard databaseFileExistsInCachesDirectory() else {
            return
        }
        
        let documentsDirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let cachesDirPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String
        let fromPath = cachesDirPath.appending("/medo_db.sqlite3")
        let toPath = documentsDirPath.appending("/medo_db.sqlite3")
        
        do {
            try FileManager.default.moveItem(atPath: fromPath, toPath: toPath)
        } catch {
            moveDatabaseIssue = error.localizedDescription
        }
    }
    
    private func databaseFileExistsInCachesDirectory() -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("medo_db.sqlite3") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            return fileManager.fileExists(atPath: filePath)
        } else {
            return false
        }
    }
    
    // MARK: - Fix UserSetting flag name
    
    private func hasSkipGetLinkInstructionsSet() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "skipGetLinkInstructions") else {
            return false
        }
        return Bool(value as! Bool)
    }

    /// `skipGetLinkInstructions` is a remnant of when the app started and I copied a bunch of code from my other app, The Library Is Open.
    private func replaceUserSettingFlag() {
        if hasSkipGetLinkInstructionsSet() {
            UserSettings().setShowExplicitContent(to: true)
            UserDefaults.standard.removeObject(forKey: "skipGetLinkInstructions")
        }
    }
}

extension AppDelegate {
    
    func createFoldersForDownloadedContent() {
        createFolder(named: InternalFolderNames.downloadedSounds)
        createFolder(named: InternalFolderNames.downloadedSongs)
    }
    
    func createFolder(named folderName: String) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let downloadedSoundsURL = documentsURL.appendingPathComponent(folderName)
        
        do {
            var isDirectory: ObjCBool = false
            if !fileManager.fileExists(atPath: downloadedSoundsURL.path, isDirectory: &isDirectory) {
                try fileManager.createDirectory(at: downloadedSoundsURL, withIntermediateDirectories: true, attributes: nil)
                print(folderName + " folder created.")
            } else {
                if isDirectory.boolValue {
                    print(folderName + " folder already exists.")
                } else {
                    print("A file with the name \(folderName) already exists.")
                }
            }
        } catch {
            print("Error creating \(folderName) folder: \(error)")
            Logger.shared.updateError("Erro ao tentar criar a pasta \(folderName): \(error.localizedDescription)")
        }
    }
}

extension AppDelegate {

    /// External Links were added on version 7.10. Because of the server architecture, EL author updates will arrive to older versions
    /// that know nothing about ELs. This func makes sure 7.10 onwards starts with the ELs in place that were ignored before.
    /// This should run only once.
    func updateExternalLinks() {
        if !hasUpdatedExternalLinksOnFirstRun {
            Task {
                let url = URL(string: APIClient.shared.serverPath + "v4/author-links-first-open")!
                do {
                    let authorsWithLinks: [Author] = try await APIClient.shared.get(from: url)
                    try authorsWithLinks.forEach { author in
                        try LocalDatabase.shared.update(author: author)
                    }
                    print("UPDATED \(authorsWithLinks.count) AUTHORS WITH LINKS")
                    hasUpdatedExternalLinksOnFirstRun = true
                } catch {
                    print(error)
                }
            }
        }
    }

    /// UserFolder change hashes were added on version 7.14.
    /// This sets initial hashes for all existing folders so the app can keep track of future changes done to them.
    /// This should run only once.
    func updateFolderChangeHashes() {
        if !hasUpdatedFolderHashesOnFirstRun {
            do {
                try UserFolderRepository(database: LocalDatabase.shared).addHashToExistingFolders()
                hasUpdatedFolderHashesOnFirstRun = true
            } catch {
                print(error)
            }
        }
    }
}
