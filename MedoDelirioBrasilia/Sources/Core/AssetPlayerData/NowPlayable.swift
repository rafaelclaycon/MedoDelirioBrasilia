/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
`NowPlayable` protocol defines customization points for the behavior an app
 must provide in order to be eligible to become the "Now Playing" app system-wide,
 and to maintain the Now Playing Info panel (and controls) correctly.
*/

import Foundation
import MediaPlayer

// Reasons for invoking the audio session interruption handler (except macOS).

enum NowPlayableInterruption {
    case began, ended(Bool), failed(Error)
}

// An app should provide a custom implementation of the `NowPlayable` protocol for each
// platform on which it runs.

protocol NowPlayable: AnyObject {
    
    // Customization point: default external playability.
    
    var defaultAllowsExternalPlayback: Bool { get }
    
    // Customization point: remote commands to register by default.
    
    var defaultRegisteredCommands: [NowPlayableCommand] { get }
    
    // Customization point: remote commands to disable by default.
    
    var defaultDisabledCommands: [NowPlayableCommand] { get }
    
    // Customization point: register and disable commands, provide a handler for registered
    // commands, and provide a handler for audio session interruptions (except macOS).
    
    func handleNowPlayableConfiguration(commands: [NowPlayableCommand],
                                        disabledCommands: [NowPlayableCommand],
                                        commandHandler: @escaping (NowPlayableCommand, MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus,
                                        interruptionHandler: @escaping (NowPlayableInterruption) -> Void) throws
    
    // Customization point: start a `NowPlayable` session, either by activating an audio session
    // or setting a playback state, depending on platform.
    
    func handleNowPlayableSessionStart() throws
    
    // Customization point: end a `NowPlayable` session, to allow other apps to become the
    // current `NowPlayable` app, by deactivating an audio session, or setting a playback
    // state, depending on platform.
    
    func handleNowPlayableSessionEnd()
    
    // Customization point: update the Now Playing Info metadata with application-supplied
    // values. The values passed into this method describe the currently playing item,
    // and the method should (typically) be invoked only once per item.
    
    func handleNowPlayableItemChange(metadata: NowPlayableStaticMetadata)
    
    // Customization point: update the Now Playing Info metadata with application-supplied
    // values. The values passed into this method describe attributes of playback that
    // change over time, such as elapsed time within the current item or the playback rate,
    // as well as attributes that require asynchronous asset loading, which aren't available
    // immediately at the start of the item.
    
    // This method should (typically) be invoked only when the playback position, duration
    // or rate changes due to user actions, or when asynchonous asset loading completes.
    
    // Note that the playback position, once set, is updated automatically according to
    // the playback rate. There is no need for explicit period updates from the app.
    
    func handleNowPlayablePlaybackChange(playing: Bool, metadata: NowPlayableDynamicMetadata)
}

// Extension methods provide useful functionality for `NowPlayable` customizations.

extension NowPlayable {
    
    // Install handlers for registered commands, and disable commands as necessary.
    
    func configureRemoteCommands(_ commands: [NowPlayableCommand],
                                 disabledCommands: [NowPlayableCommand],
                                 commandHandler: @escaping (NowPlayableCommand, MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus) throws {
        
        // Check that at least one command is being handled.
        
        guard commands.count > 1 else { throw NowPlayableError.noRegisteredCommands }
        
        // Configure each command.
        
        for command in NowPlayableCommand.allCases {
            
            // Remove any existing handler.
            
            command.removeHandler()
            
            // Add a handler if necessary.
            
            if commands.contains(command) {
                command.addHandler(commandHandler)
            }
            
            // Disable the command if necessary.
            
            command.setDisabled(disabledCommands.contains(command))
        }
    }
    
    // Set per-track metadata. Implementations of `handleNowPlayableItemChange(metadata:)`
    // will typically invoke this method.
    
    func setNowPlayingMetadata(_ metadata: NowPlayableStaticMetadata) {
       
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String: Any]()
        
        NSLog("%@", "**** Set track metadata: title \(metadata.title)")
        nowPlayingInfo[MPNowPlayingInfoPropertyAssetURL] = metadata.assetURL
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = metadata.mediaType.rawValue
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = metadata.isLiveStream
        nowPlayingInfo[MPMediaItemPropertyTitle] = metadata.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = metadata.artist
        nowPlayingInfo[MPMediaItemPropertyArtwork] = metadata.artwork
        nowPlayingInfo[MPMediaItemPropertyAlbumArtist] = metadata.albumArtist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = metadata.albumTitle
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    // Set playback info. Implementations of `handleNowPlayablePlaybackChange(playing:rate:position:duration:)`
    // will typically invoke this method.
    
    func setNowPlayingPlaybackInfo(_ metadata: NowPlayableDynamicMetadata) {
        
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        
        NSLog("%@", "**** Set playback info: rate \(metadata.rate), position \(metadata.position), duration \(metadata.duration)")
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = metadata.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = metadata.position
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = metadata.rate
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
        nowPlayingInfo[MPNowPlayingInfoPropertyCurrentLanguageOptions] = metadata.currentLanguageOptions
        nowPlayingInfo[MPNowPlayingInfoPropertyAvailableLanguageOptions] = metadata.availableLanguageOptionGroups
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
}
