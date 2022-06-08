import SwiftUI

var player: AudioPlayer?
var database = LocalDatabase()
let networkRabbit = NetworkRabbit(serverPath: "http://170.187.145.233:8080/api/")

let soundsLastUpdateDate: String = "08/06/2022"
let songsLastUpdateDate: String = "23/05/2022"

@main
struct MedoDelirioBrasiliaApp: App {

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }

}
