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

        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    static func createVideo(fromImage imageName: String, duration: Int) {
        // Create a CIImage
        guard let uikitImage = UIImage(named: imageName), let staticImage = CIImage(image: uikitImage) else {
            fatalError("Invalid image")
        }
        
        // create a variable to hold the pixelBuffer
        var pixelBuffer: CVPixelBuffer?
        
        // set some standard attributes
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
        // create the width and height of the buffer to match the image
        let width: Int = Int(staticImage.extent.size.width)
        let height: Int = Int(staticImage.extent.size.height)
        
        // create a buffer (notice it uses an in/out parameter for the pixelBuffer variable)
        CVPixelBufferCreate(kCFAllocatorDefault,
                            width,
                            height,
                            kCVPixelFormatType_32BGRA,
                            attrs,
                            &pixelBuffer)
        
        // create a CIContext
        let context = CIContext()
        
        // use the context to render the image into the pixelBuffer
        context.render(staticImage, to: pixelBuffer!)
        
        // 2nd part
        
        //let assetWriterSettings = [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey : 400, AVVideoHeightKey: 400] as [String : Any]
        
        // generate a file url to store the video. some_image.jpg becomes some_image.mov
        guard let imageNameRoot = imageName.split(separator: ".").first, let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(imageNameRoot).mov") else {
            fatalError("Invalid URL")
        }
        // delete any old file
        do {
            try FileManager.default.removeItem(at: outputMovieURL)
        } catch {
            print("Could not remove file \(error.localizedDescription)")
        }
        
        // create an assetwriter instance
        guard let assetwriter = try? AVAssetWriter(outputURL: outputMovieURL, fileType: .mov) else {
            abort()
        }
        
        let assetWriterSettings = [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1000, AVVideoHeightKey: 1000] as [String: Any]
        
        // create a single video input
        let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: assetWriterSettings)
        // create an adaptor for the pixel buffer
        let assetWriterAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: nil)
        // add the input to the asset writer
        assetwriter.add(assetWriterInput)
        // begin the session
        assetwriter.startWriting()
        assetwriter.startSession(atSourceTime: CMTime.zero)
        // determine how many frames we need to generate
        let framesPerSecond = 30
        
        // duration is the number of seconds for the final video
        let totalFrames = duration * framesPerSecond
        var frameCount = 0
        while frameCount < totalFrames {
            if assetWriterInput.isReadyForMoreMediaData {
                let frameTime = CMTimeMake(value: Int64(frameCount), timescale: Int32(framesPerSecond))
                //append the contents of the pixelBuffer at the correct time
                assetWriterAdaptor.append(pixelBuffer!, withPresentationTime: frameTime)
                frameCount+=1
            }
        }
        
        // close everything
        assetWriterInput.markAsFinished()
        assetwriter.finishWriting {
            pixelBuffer = nil
            //outputMovieURL now has the video
            print("Finished video location: \(outputMovieURL)")
        }
    }

}
