import SwiftUI

var player: AudioPlayer?
var database = LocalDatabase()

let networkRabbit = NetworkRabbit(serverPath: CommandLine.arguments.contains("-UNDER_DEVELOPMENT") ? "http://localhost:8080/api/" : "http://170.187.145.233:8080/api/")
let podium = Podium(database: database, networkRabbit: networkRabbit)

let soundsLastUpdateDate: String = "28/07/2022"
let songsLastUpdateDate: String = "28/07/2022"

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
        if let favoriteCount = try? database.getFavoriteCount() {
            Logger.logFavorites(favoriteCount: favoriteCount, callMoment: "application(didFinishLaunchingWithOptions)", needsMigration: database.needsMigration)
        } else {
            Logger.logFavorites(favoriteCount: 0, callMoment: "application(didFinishLaunchingWithOptions) - getFavoriteCount failed", needsMigration: database.needsMigration)
        }
        
        do {
            try database.migrateIfNeeded()
        } catch {
            fatalError("Failed to migrate database: \(error)")
        }
        
        //print(database)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        return true
    }
    
    @objc func appMovedToBackground() {
        if let favoriteCount = try? database.getFavoriteCount() {
            Logger.logFavorites(favoriteCount: favoriteCount, callMoment: "willResignActiveNotification", needsMigration: false)
        } else {
            Logger.logFavorites(favoriteCount: 0, callMoment: "willResignActiveNotification - getFavoriteCount failed", needsMigration: false)
        }
    }

}
