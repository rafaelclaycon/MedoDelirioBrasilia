//
//  AudioWaveformGenerator.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 24/02/26.
//

import AVFoundation

enum AudioWaveformGenerator {

    /// Reads the audio file at `url` and returns `barCount` normalised amplitude
    /// values in the range 0…1, suitable for waveform visualisation.
    static func generate(from url: URL, barCount: Int) async throws -> [Float] {
        try await Task.detached(priority: .userInitiated) {
            let file = try AVAudioFile(forReading: url)
            let totalFrames = AVAudioFrameCount(file.length)
            guard totalFrames > 0, barCount > 0 else { return [Float](repeating: 0, count: barCount) }

            guard let format = AVAudioFormat(
                commonFormat: .pcmFormatFloat32,
                sampleRate: file.fileFormat.sampleRate,
                channels: 1,
                interleaved: false
            ) else {
                return [Float](repeating: 0, count: barCount)
            }

            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrames)!
            try file.read(into: buffer)

            guard let samples = buffer.floatChannelData?[0] else {
                return [Float](repeating: 0, count: barCount)
            }

            let framesPerBar = Int(totalFrames) / barCount
            guard framesPerBar > 0 else { return [Float](repeating: 0, count: barCount) }

            var bars = [Float](repeating: 0, count: barCount)
            
            for i in 0..<barCount {
                let start = i * framesPerBar
                let end = min(start + framesPerBar, Int(totalFrames))
                var sum: Float = 0
                for j in start..<end {
                    sum += abs(samples[j])
                }
                bars[i] = sum / Float(end - start)
            }

            let peak = bars.max() ?? 1
            if peak > 0 {
                for i in 0..<barCount {
                    bars[i] /= peak
                }
            }

            return bars
        }.value
    }
}
