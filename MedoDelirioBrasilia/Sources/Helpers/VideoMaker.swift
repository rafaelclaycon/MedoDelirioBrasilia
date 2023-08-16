import UIKit
import AVFoundation

class VideoMaker {

    static func createVideo(from audioFilename: String,
                            with sourceImage: UIImage,
                            contentTitle: String,
                            exportType: IntendedVideoDestination,
                            completion: @escaping (String?, VideoMakerError?) -> Void) throws {
        guard audioFilename.isEmpty == false else {
            throw VideoMakerError.soundFilepathIsEmpty
        }
        
        guard let path = Bundle.main.path(forResource: audioFilename, ofType: nil) else {
            throw VideoMakerError.unableToFindSoundFile
        }
        
        let url = URL(fileURLWithPath: path)
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let audioDuration = VideoMaker.getAudioFileDuration(fileURL: url) else {
                return completion(nil, .couldNotObtainAudioDuration)
            }
            
            do {
                try VideoMaker.createVideo(fromImage: sourceImage,
                                           withDuration: audioDuration,
                                           andName: contentTitle,
                                           soundFilepath: audioFilename,
                                           exportType: exportType) { videoPath, error in
                    guard let videoPath = videoPath else {
                        return completion(nil, .unableToFindVideoFile)
                    }
                    completion(videoPath, nil)
                }
            } catch {
                completion(nil, .unknownError)
            }
        }
    }
    
    static func getAudioFileDuration(fileURL: URL) -> CGFloat? {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            return CGFloat(audioPlayer.duration)
        } catch {
            assertionFailure("Failed creating audio player: \(error).")
            return nil
        }
    }
    
    // TODO: - Remove this method when dropping support for iOS 15.
    static func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.black
        let textFont = UIFont.systemFont(ofSize: 72, weight: .bold)

        //let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1.0)

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
    
    static func mergeVideoWithAudio(videoUrl: URL,
                                    audioUrl: URL,
                                    videoName: String,
                                    exportType: IntendedVideoDestination,
                                    success: @escaping ((URL) -> Void),
                                    failure: @escaping ((Error?) -> Void)) {
        return
    }
    
    static func createVideo(fromImage image: UIImage,
                            withDuration duration: CGFloat,
                            andName videoName: String,
                            soundFilepath: String,
                            exportType: IntendedVideoDestination,
                            completionHandler: @escaping (String?, VideoMakerError?) -> Void) throws {
        guard soundFilepath.isEmpty == false else {
            throw VideoMakerError.soundFilepathIsEmpty
        }
        
        guard let soundPath = Bundle.main.path(forResource: soundFilepath, ofType: nil) else {
            throw VideoMakerError.unableToFindSoundFile
        }
        
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
            print("Could not remove file: \(error.localizedDescription)")
        }
        
        guard let assetwriter = try? AVAssetWriter(outputURL: outputMovieURL, fileType: .mov) else {
            abort()
        }
        
        var videoWidth: Int = 0
        var videoHeight: Int = 0
        
        if exportType == IntendedVideoDestination.twitter {
            videoWidth = 1000
            videoHeight = 1000
        } else {
            videoWidth = 1080
            videoHeight = 1920
        }
        
        let assetWriterSettings = [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: videoWidth, AVVideoHeightKey: videoHeight] as [String: Any]
        let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: assetWriterSettings)
        let assetWriterAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: nil)
        
        assetwriter.add(assetWriterInput)
        
        assetwriter.startWriting()
        assetwriter.startSession(atSourceTime: CMTime.zero)
        
        let framesPerSecond = 30.0
        
        let totalFrames = duration * framesPerSecond
        var frameCount = 0.0
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
            
            let soundURL = URL(fileURLWithPath: soundPath)
            
            mergeVideoWithAudio(videoUrl: outputMovieURL, audioUrl: soundURL, videoName: videoName, exportType: exportType) { videoURL in
                completionHandler(videoURL.path, nil)
            } failure: { error in
                if error != nil {
                    completionHandler(nil, VideoMakerError.failedToMergeSoundAndVideo)
                }
            }
        }
    }

}

enum VideoMakerError: Error {

    case invalidImage
    case invalidURL
    case soundFilepathIsEmpty
    case unableToFindSoundFile
    case failedToMergeSoundAndVideo
    case couldNotObtainAudioDuration
    case unableToFindVideoFile
    case unknownError

}
