import SwiftUI

var player: AudioPlayer?
var database = LocalDatabase()

//let networkRabbit = NetworkRabbit(serverPath: "https://654e-2804-1b3-8640-96df-d0b4-dd5d-6922-bb1b.sa.ngrok.io/api/")
let networkRabbit = NetworkRabbit(serverPath: CommandLine.arguments.contains("-UNDER_DEVELOPMENT") ? "http://127.0.0.1:8080/api/" : "http://170.187.145.233:8080/api/")
let podium = Podium(database: database, networkRabbit: networkRabbit)

let soundsLastUpdateDate: String = "27/10/2022"
let songsLastUpdateDate: String = "25/10/2022"

var moveDatabaseIssue: String = .empty

@main
struct MedoDelirioBrasiliaApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }

}

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Fix missing favorites bug
        moveDatabaseFileIfNeeded()
        
        do {
            try database.migrateIfNeeded()
        } catch {
            fatalError("Failed to migrate database: \(error)")
        }
        
        //print(database)
        
        collectTelemetry()
        
        return true
    }
    
    private func collectTelemetry() {
        sendDeviceModelNameToServer()
        sendStillAliveSignalToServer()
    }
    
    private func sendDeviceModelNameToServer() {
//        guard UserSettings.getHasSentDeviceModelToServer() == false else {
//            return
//        }
//        guard UIDevice.modelName.contains("Simulator") == false else {
//            return
//        }
//        guard CommandLine.arguments.contains("-UNDER_DEVELOPMENT") == false else {
//            return
//        }
//
//        let info = ClientDeviceInfo(installId: UIDevice.deviceIDForVendor, modelName: UIDevice.modelName)
//        networkRabbit.post(clientDeviceInfo: info) { success, error in
//            if let success = success, success {
//                UserSettings.setHasSentDeviceModelToServer(to: true)
//            }
//        }
    }
    
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
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        if AppPersistentMemory.getShouldRetrySendingDevicePushToken() {
            let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
            let token = tokenParts.joined()
            //print("Device Token: \(token)")

            let device = PushDevice(installId: UIDevice.deviceIDForVendor, pushToken: token)
            networkRabbit.post(pushDevice: device) { success, error in
                guard let success = success, success else {
                    AppPersistentMemory.setShouldRetrySendingDevicePushToken(to: true)
                    return
                }
                AppPersistentMemory.setShouldRetrySendingDevicePushToken(to: false)
            }
        }
    }
    
    private func sendStillAliveSignalToServer() {
//        guard UIDevice.modelName.contains("Simulator") == false else {
//            return
//        }
//        guard CommandLine.arguments.contains("-UNDER_DEVELOPMENT") == false else {
//            return
//        }
        
        let lastDate = UserSettings.getLastSendDateOfStillAliveSignalToServer()
        
        // Should only send 1 still alive signal per day
        guard lastDate == nil || lastDate!.onlyDate! < Date.now.onlyDate! else {
            return
        }
        
        let signal = StillAliveSignal(installId: UIDevice.deviceIDForVendor,
                                      modelName: UIDevice.modelName,
                                      systemName: UIDevice.current.systemName,
                                      systemVersion: UIDevice.current.systemVersion,
                                      isiOSAppOnMac: ProcessInfo.processInfo.isiOSAppOnMac,
                                      appVersion: Versioneer.appVersion,
                                      currentTimeZone: TimeZone.current.abbreviation() ?? .empty,
                                      dateTime: Date.now.iso8601withFractionalSeconds)
        networkRabbit.post(signal: signal) { success, error in
            if success != nil, success == true {
                UserSettings.setLastSendDateOfStillAliveSignalToServer(to: Date.now)
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register: \(error.localizedDescription)")
    }

}
