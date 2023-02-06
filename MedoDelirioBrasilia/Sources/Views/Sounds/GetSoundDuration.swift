//
//  GetSoundDuration.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 06/02/23.
//

import AVFoundation

func getDuration(of fileUrl: URL) -> Int {
    let asset = AVURLAsset(url: fileUrl)
    return customRound(asset.duration.seconds)
}

func getDurationDouble(of fileUrl: URL) -> Double {
    let asset = AVURLAsset(url: fileUrl)
    return asset.duration.seconds
}

func customRound(_ value: Double) -> Int {
    return Int(value.rounded(.toNearestOrAwayFromZero))
}
