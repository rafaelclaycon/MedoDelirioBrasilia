//
//  PlaylistDetailViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/02/23.
//

import Combine
import SwiftUI

class PlaylistDetailViewViewModel: ObservableObject {

    @Published var sounds = [Sound]()
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
            self.sounds = [Sound]()
            self.hasSoundsToDisplay = false
            return
        }
        
        let sounds = soundData.filter { sound in
            playlistContents.contains { $0.contentId == sound.id }
        }
        
        guard sounds.count > 0 else {
            self.sounds = [Sound]()
            self.hasSoundsToDisplay = false
            return
        }
        
        self.sounds = sounds
        
        for i in stride(from: 0, to: self.sounds.count, by: 1) {
            self.sounds[i].authorName = authorData.first(where: { $0.id == self.sounds[i].authorId })?.name ?? Shared.unknownAuthor
            // DateAdded here is date added to folder not to the app as it means outside folders.
            self.sounds[i].dateAdded = playlistContents.first(where: { $0.contentId == self.sounds[i].id })?.dateAdded
        }
        
        self.hasSoundsToDisplay = true
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
                    
                    if self.currentTrackIndex >= self.sounds.count {
                        self.doPlaylistCleanup()
                        return
                    }
                    
                    self.playSound(fromPath: self.sounds[self.currentTrackIndex].filename, withId: self.sounds[self.currentTrackIndex].id)
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
        guard let firstSound = sounds.first else { return }
        isPlayingPlaylist = true
        playSound(fromPath: firstSound.filename, withId: firstSound.id)
    }
    
    func playFrom(sound: Sound) {
        guard let soundIndex = sounds.firstIndex(where: { $0.id == sound.id }) else { return }
        let soundInArray = sounds[soundIndex]
        currentTrackIndex = soundIndex
        isPlayingPlaylist = true
        playSound(fromPath: soundInArray.filename, withId: soundInArray.id)
    }
    
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
