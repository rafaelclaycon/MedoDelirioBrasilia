//
//  WaveformView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 04/02/23.
//

import SwiftUI
import AVFoundation

struct WaveformView: View {

    let url: URL
    
    private var audioData: [Float] {
        return extractAudioData(from: url)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<self.audioData.count, id: \.self) { index in
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 2, height: CGFloat(self.audioData[index]) * geometry.size.height)
                    .offset(x: CGFloat(index) * 2)
            }
        }
    }
    
    init(url: URL) {
        self.url = url
    }
    
    func extractAudioData(from url: URL) -> [Float] {
        let asset = AVURLAsset(url: url)
        let track = asset.tracks(withMediaType: .audio).first!
        let reader = try! AVAssetReader(asset: asset)
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: [AVFormatIDKey: kAudioFormatLinearPCM])
        reader.add(output)
        reader.startReading()
        
        let sampleBuffer = reader.outputs.first!.copyNextSampleBuffer()!
        let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer)!
        let length = CMBlockBufferGetDataLength(blockBuffer)
        var samples = [Float](repeating: 0, count: length / 4)
        CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: &samples)
        
        return samples
    }

}

struct WaveformView_Previews: PreviewProvider {

    static var previews: some View {
        WaveformView(url: URL(string: "")!)
    }

}
