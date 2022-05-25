import SwiftUI

var player: AudioPlayer?
var database = LocalDatabase()

let soundsLastUpdateDate: String = "25/05/2022"
let songsLastUpdateDate: String = "23/05/2022"

@main
struct MedoDelirioBrasiliaApp: App {

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }

}
