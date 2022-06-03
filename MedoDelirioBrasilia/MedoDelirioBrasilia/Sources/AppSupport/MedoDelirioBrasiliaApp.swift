import SwiftUI

var player: AudioPlayer?
var database = LocalDatabase()
let networkRabbit = NetworkRabbit(serverPath: "http://170.187.145.233:8080")

let soundsLastUpdateDate: String = "29/05/2022"
let songsLastUpdateDate: String = "23/05/2022"

@main
struct MedoDelirioBrasiliaApp: App {

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }

}
