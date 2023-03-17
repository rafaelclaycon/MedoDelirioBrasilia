//
//  PlaylistDetailViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/02/23.
//

import Combine
import SwiftUI

class PlaylistDetailViewViewModel: ObservableObject {

    @Published var content = [PlaylistContent]()
    @Published var hasSoundsToDisplay: Bool = false
    @Published var nowPlayingKeeper = Set<String>()
    
    // Playlist
    @Published var isPlayingPlaylist: Bool = false
    private var currentTrackIndex: Int = 0
    
    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var alertType: FolderDetailAlertType = .ok
    
    func reloadSoundList(withPlaylistContents playlistContents: [PlaylistContent]?) {
        guard let playlistContents = playlistContents else {
            content = []
            hasSoundsToDisplay = false
            return
        }
        
        var sounds = soundData.filter { sound in
            playlistContents.contains { $0.contentId == sound.id }
        }
        
        guard sounds.count > 0 else {
            content = []
            hasSoundsToDisplay = false
            return
        }
        
        for i in 0..<sounds.count {
            sounds[i].authorName = authorData.first(where: { $0.id == sounds[i].authorId })?.name ?? Shared.unknownAuthor
            // DateAdded here is date added to folder not to the app as it means outside folders.
            sounds[i].dateAdded = playlistContents.first(where: { $0.contentId == sounds[i].id })?.dateAdded
        }
        
        content = []
        for i in 0..<playlistContents.count {
            content.append(PlaylistContent(content: playlistContents[i], sound: sounds.first(where: { $0.id == playlistContents[i].contentId })))
        }
        
        hasSoundsToDisplay = true
        
        print(self.content)
    }
    
    private func sortSoundsInPlaceByOrderDescending() {
        content.sort(by: { $0.order > $1.order })
    }
    
//    func getSoundCount() -> String {
//        if sounds.count == 1 {
//            return "1 SOM"
//        } else {
//            return "\(sounds.count) SONS"
//        }
//    }
    
    func playSound(fromPath filepath: String, withId soundId: String) {
        guard filepath.isEmpty == false else {
            return
        }
        
        guard let path = Bundle.main.path(forResource: filepath, ofType: nil) else {
            return showUnableToGetSoundAlert()
        }
        let url = URL(fileURLWithPath: path)
        
        nowPlayingKeeper.removeAll()
        nowPlayingKeeper.insert(soundId)

        player = AudioPlayer(url: url, update: { [weak self] state in
            guard let self = self else { return }
            if state?.activity == .stopped {
                self.nowPlayingKeeper.removeAll()
                
                if self.isPlayingPlaylist {
                    self.currentTrackIndex += 1
                    
                    if self.currentTrackIndex >= self.content.count {
                        self.doPlaylistCleanup()
                        return
                    }
                    
                    guard let sound = self.content[self.currentTrackIndex].sound else { return }
                    
                    self.playSound(fromPath: sound.filename, withId: sound.id)
                }
            }
        })
        
        player?.togglePlay()
    }
    
    func stopPlaying() {
        if nowPlayingKeeper.count > 0 {
            player?.togglePlay()
            nowPlayingKeeper.removeAll()
            doPlaylistCleanup()
        }
    }
    
    func sendUsageMetricToServer(action: String, folderName: String) {
        let usageMetric = UsageMetric(customInstallId: UIDevice.customInstallId,
                                      originatingScreen: "FolderDetailView(\(folderName))",
                                      destinationScreen: action,
                                      systemName: UIDevice.current.systemName,
                                      isiOSAppOnMac: ProcessInfo.processInfo.isiOSAppOnMac,
                                      appVersion: Versioneer.appVersion,
                                      dateTime: Date.now.iso8601withFractionalSeconds,
                                      currentTimeZone: TimeZone.current.abbreviation() ?? .empty)
        networkRabbit.post(usageMetric: usageMetric)
    }
    
    // MARK: - Playlist
    
    func playAllSoundsOneAfterTheOther() {
        guard let firstContent = content.first, let sound = firstContent.sound else { return }
        isPlayingPlaylist = true
        playSound(fromPath: sound.filename, withId: sound.id)
    }
    
//    func playFrom(sound: Sound) {
//        guard let soundIndex = content.firstIndex(where: { $0.id == sound.id }) else { return }
//        let soundInArray = sounds[soundIndex]
//        currentTrackIndex = soundIndex
//        isPlayingPlaylist = true
//        playSound(fromPath: soundInArray.filename, withId: soundInArray.id)
//    }
    
    func doPlaylistCleanup() {
        currentTrackIndex = 0
        isPlayingPlaylist = false
    }
    
    // MARK: - Alerts
    
    func showUnableToGetSoundAlert() {
        TapticFeedback.error()
        alertTitle = Shared.soundNotFoundAlertTitle
        alertMessage = Shared.soundNotFoundAlertMessage
        alertType = .ok
        showAlert = true
    }
    
    func showSoundRemovalConfirmation(soundTitle: String) {
        alertTitle = "Remover \"\(soundTitle)\"?"
        alertMessage = "O som continuará disponível fora da pasta."
        alertType = .removeSingleSound
        showAlert = true
    }
    
    func showRemoveMultipleSoundsConfirmation() {
        alertTitle = "Remover os sons selecionados?"
        alertMessage = "Os sons continuarão disponíveis fora da pasta."
        alertType = .removeMultipleSounds
        showAlert = true
    }

}
