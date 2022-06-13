import SwiftUI

var player: AudioPlayer?
var database = LocalDatabase()
let networkRabbit = NetworkRabbit(serverPath: "http://170.187.145.233:8080/api/")

//let soundsLastUpdateDate: String = "12/06/2022"
let soundsLastUpdateDate: String = "2022-06-12T01:00:00+0000"
//let songsLastUpdateDate: String = "23/05/2022"
let songsLastUpdateDate: String = "2022-05-23T01:00:00+0000"

@main
struct MedoDelirioBrasiliaApp: App {

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }

}
