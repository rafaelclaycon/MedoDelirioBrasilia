//
//  MainSoundContainerViewModel+SpotlightIndex.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 11/01/25.
//

import Foundation
import CoreSpotlight
import UIKit

extension MainSoundContainerViewModel {

    public func index(sounds: [Sound]) {
        sounds.forEach { sound in
            addContentToIndex(sound)
        }
    }

    private func addContentToIndex(_ sound: Sound) {
        let attributeSet = CSSearchableItemAttributeSet(contentType: UTType.audio)
        attributeSet.title = sound.title
        attributeSet.artist = sound.authorName
        attributeSet.duration = NSNumber(value: sound.duration)
        attributeSet.thumbnailData = cover()

        let item = CSSearchableItem(uniqueIdentifier: sound.id, domainIdentifier: nil, attributeSet: attributeSet)

        let defaultIndex = CSSearchableIndex.default()
        defaultIndex.indexSearchableItems([item]) { error in
            if let error {
                return print(error.localizedDescription)
            }
            print("\(sound.title) indexed.")
        }
    }

    private func cover() -> Data? {
        guard let image = UIImage(named: "spotlightIndexSoundImage") else {
            return nil
        }
        return image.pngData()
    }
}
