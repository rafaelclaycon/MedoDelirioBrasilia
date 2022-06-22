import SwiftUI

var player: AudioPlayer?
var database = LocalDatabase()
let networkRabbit = NetworkRabbit(serverPath: CommandLine.arguments.contains("-UNDER_DEVELOPMENT") ? "http://localhost:8080/api/" : "http://170.187.145.233:8080/api/")
let podium = Podium(database: database, networkRabbit: networkRabbit)

let soundsLastUpdateDate: String = "20/06/2022"
let songsLastUpdateDate: String = "23/05/2022"

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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        do {
            try database.migrateIfNeeded()
        } catch {
            fatalError("Failed to migrate database: \(error)")
        }
        
        //print(database)
        
        sendDeviceModelNameToServer()
        sendStillAliveSignalToServer()
        
        return true
    }
    
    private func collectTelemetry() {
        sendDeviceModelNameToServer()
        sendStillAliveSignalToServer()
    }
    
    private func sendDeviceModelNameToServer() {
        guard UserSettings.getHasSentDeviceModelToServer() == false else {
            return
        }
        guard UIDevice.modelName.contains("Simulator") == false else {
            return
        }
        guard CommandLine.arguments.contains("-UNDER_DEVELOPMENT") == false else {
            return
        }
        
        let info = ClientDeviceInfo(installId: UIDevice.current.identifierForVendor?.uuidString ?? "", modelName: UIDevice.modelName)
        networkRabbit.post(clientDeviceInfo: info) { success, error in
            if let success = success, success {
                UserSettings.setHasSentDeviceModelToServer(to: true)
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
        guard lastDate == nil || (lastDate!.onlyDate! < Date.now.onlyDate!) else {
            return
        }
        
        let signal = StillAliveSignal(systemName: UIDevice.current.systemName,
                                      systemVersion: UIDevice.current.systemVersion,
                                      currentTimeZone: TimeZone.current.abbreviation() ?? "",
                                      dateTime: Date.now)
        networkRabbit.post(signal: signal) { success, error in
            if success {
                UserSettings.setLastSendDateOfStillAliveSignalToServer(to: Date.now)
            }
        }
    }

}
