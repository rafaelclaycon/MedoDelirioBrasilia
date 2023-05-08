import AVFoundation
import Foundation

class AudioPlayer: NSObject, AVAudioPlayerDelegate {

    enum Activity {
        case stopped
        case playing
        case paused
    }

    struct State {
        var currentTime: TimeInterval
        var duration: TimeInterval
        var activity: Activity
    }

    private var audioPlayer: AVAudioPlayer
    private var timer: Timer?
    private var update: (State?) -> Void

    init?(url: URL, update: @escaping (State?) -> Void) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            return nil
        }

        if let player = try? AVAudioPlayer(contentsOf: url) {
            audioPlayer = player
            self.update = update
        } else {
            return nil
        }

        super.init()

        audioPlayer.delegate = self
    }

    func togglePlay() {
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            timer?.invalidate()
            timer = nil
            notify()
        } else {
            audioPlayer.play()
            if let t = timer {
                t.invalidate()
            }
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                guard let s = self else { return }
                s.notify()
            }
        }
    }

    var state: AudioPlayer.State {
        State(currentTime: audioPlayer.currentTime, duration: audioPlayer.duration, activity: activity)
    }

    func notify() {
        update(state)
    }

    func setProgress(_ time: TimeInterval) {
        audioPlayer.currentTime = time
        notify()
    }

    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully flag: Bool) {
        timer?.invalidate()
        timer = nil
        if flag {
            notify()
        } else {
            update(nil)
        }
    }

    var duration: TimeInterval {
        audioPlayer.duration
    }

    var activity: Activity {
        audioPlayer.isPlaying ? .playing : isPaused ? .paused : .stopped
    }
    
    var isPlaying: Bool {
        audioPlayer.isPlaying
    }

    var isPaused: Bool {
        !audioPlayer.isPlaying && audioPlayer.currentTime > 0
    }
    
    func stop() {
        audioPlayer.pause()
        timer?.invalidate()
        timer = nil
        notify()
    }

    func cancel() {
        audioPlayer.stop()
        timer?.invalidate()
    }
    
    func prepareToPlay() {
        audioPlayer.prepareToPlay()
    }

    deinit {
        cancel()
    }

}
