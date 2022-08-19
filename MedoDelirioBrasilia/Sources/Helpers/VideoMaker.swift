import UIKit
import AVFoundation

class VideoMaker {

    static func getAudioFileDuration(fileURL: URL) -> Int? {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            return Int(audioPlayer.duration)
        } catch {
            assertionFailure("Failed creating audio player: \(error).")
            return nil
        }
    }
    
    static func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica Bold", size: 72)!

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let rect = CGRect(origin: point, size: CGSize(width: image.size.width - 80, height: image.size.height))
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func mergeVideoWithAudio(videoUrl: URL,
                             audioUrl: URL,
                             success: @escaping ((URL) -> Void),
                             failure: @escaping ((Error?) -> Void)) {
        let mixComposition: AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack: [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack: [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        
        let aVideoAsset: AVAsset = AVAsset(url: videoUrl)
        let aAudioAsset: AVAsset = AVAsset(url: audioUrl)
        
        if let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid), let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
            mutableCompositionVideoTrack.append(videoTrack)
            mutableCompositionAudioTrack.append(audioTrack)

            if let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: .video).first, let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: .audio).first {
                do {
                    try mutableCompositionVideoTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)

                    let videoDuration = aVideoAsset.duration
                    if CMTimeCompare(videoDuration, aAudioAsset.duration) == -1 {
                        try mutableCompositionAudioTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: CMTime.zero)
                    } else if CMTimeCompare(videoDuration, aAudioAsset.duration) == 1 {
                        var currentTime = CMTime.zero
                        while true {
                            var audioDuration = aAudioAsset.duration
                            let totalDuration = CMTimeAdd(currentTime, audioDuration)
                            if CMTimeCompare(totalDuration, videoDuration) == 1 {
                                audioDuration = CMTimeSubtract(totalDuration, videoDuration)
                            }
                            try mutableCompositionAudioTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: currentTime)

                            currentTime = CMTimeAdd(currentTime, audioDuration)
                            if CMTimeCompare(currentTime, videoDuration) == 1 || CMTimeCompare(currentTime, videoDuration) == 0 {
                                break
                            }
                        }
                    }
                    videoTrack.preferredTransform = aVideoAssetTrack.preferredTransform
                } catch {
                    print(error)
                }
                
                totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration)
               }
           }

           let mutableVideoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
           mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
           mutableVideoComposition.renderSize = CGSize(width: 480, height: 640)

           if let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
               let outputURL = URL(fileURLWithPath: documentsPath).appendingPathComponent("\("fileName").m4v")

               do {
                   if FileManager.default.fileExists(atPath: outputURL.path) {
                       try FileManager.default.removeItem(at: outputURL)
                   }
               } catch { }

               if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
                   exportSession.outputURL = outputURL
                   exportSession.outputFileType = AVFileType.mp4
                   exportSession.shouldOptimizeForNetworkUse = true
                   
                   // try to export the file and handle the status cases
                   exportSession.exportAsynchronously(completionHandler: {
                       switch exportSession.status {
                       case .failed:
                           if let error = exportSession.error {
                               failure(error)
                           }

                       case .cancelled:
                           if let error = exportSession.error {
                               failure(error)
                           }

                       default:
                           print("finished")
                           success(outputURL)
                       }
               })
           } else {
               failure(nil)
           }
        }
    }
    
    static func createVideo(fromImage image: UIImage,
                            withDuration duration: Int,
                            andName videoName: String,
                            completionHandler: @escaping (String?) -> Void) throws {
        guard let staticImage = CIImage(image: image) else {
            throw VideoMakerError.invalidImage
        }
        
        var pixelBuffer: CVPixelBuffer?
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
        let width: Int = Int(staticImage.extent.size.width)
        let height: Int = Int(staticImage.extent.size.height)
        
        CVPixelBufferCreate(kCFAllocatorDefault,
                            width,
                            height,
                            kCVPixelFormatType_32BGRA,
                            attrs,
                            &pixelBuffer)
        
        let context = CIContext()
        
        context.render(staticImage, to: pixelBuffer!)
        
        guard let imageNameRoot = videoName.split(separator: ".").first, let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(imageNameRoot).mov") else {
            throw VideoMakerError.invalidURL
        }
        
        // Delete any old file
        do {
            try FileManager.default.removeItem(at: outputMovieURL)
        } catch {
            print("Could not remove file \(error.localizedDescription)")
        }
        
        guard let assetwriter = try? AVAssetWriter(outputURL: outputMovieURL, fileType: .mov) else {
            abort()
        }
        
        let assetWriterSettings = [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1000, AVVideoHeightKey: 1000] as [String: Any]
        let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: assetWriterSettings)
        let assetWriterAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: nil)
        
        assetwriter.add(assetWriterInput)
        
        assetwriter.startWriting()
        assetwriter.startSession(atSourceTime: CMTime.zero)
        
        let framesPerSecond = 30
        
        let totalFrames = duration * framesPerSecond
        var frameCount = 0
        while frameCount < totalFrames {
            if assetWriterInput.isReadyForMoreMediaData {
                let frameTime = CMTimeMake(value: Int64(frameCount), timescale: Int32(framesPerSecond))
                assetWriterAdaptor.append(pixelBuffer!, withPresentationTime: frameTime)
                frameCount+=1
            }
        }
        
        assetWriterInput.markAsFinished()
        assetwriter.finishWriting {
            pixelBuffer = nil
            
            
            
            completionHandler(outputMovieURL.path)
        }
    }

}

enum VideoMakerError: Error {

    case invalidImage
    case invalidURL

}
