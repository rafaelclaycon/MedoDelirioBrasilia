import SwiftUI

var player: AudioPlayer?
var database = LocalDatabase()
let networkRabbit = NetworkRabbit(serverPath: CommandLine.arguments.contains("-UNDER_DEVELOPMENT") ? "https://7e25-2804-1b3-8643-6734-3920-db5b-c065-1789.sa.ngrok.io/api/" : "http://170.187.145.233:8080/api/")
let podium = Podium(database: database, networkRabbit: networkRabbit)

let soundsLastUpdateDate: String = "16/07/2022"
let songsLastUpdateDate: String = "16/07/2022"

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
        do {
            try database.migrateIfNeeded()
        } catch {
            fatalError("Failed to migrate database: \(error)")
        }
        
        //print(database)
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        if AppPersistentMemory.getShouldRetrySendingDevicePushToken() {
            let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
            let token = tokenParts.joined()
            print("Device Token: \(token)")
            
            let device = PushDevice(installId: UIDevice.identifiderForVendor, pushToken: token)
            networkRabbit.post(pushDevice: device) { success, error in
                guard let success = success, success else {
                    AppPersistentMemory.setShouldRetrySendingDevicePushToken(to: true)
                    return
                }
                AppPersistentMemory.setShouldRetrySendingDevicePushToken(to: false)
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
