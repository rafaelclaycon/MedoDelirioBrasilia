//
//  FileLocatorHandler.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 15/11/24.
//

import Foundation

final class FileLocatorHandler: ShareHandler {

    var nextHandler: ShareHandler?

    func handle(sound: Sound, context: inout ShareContext) async throws {
        guard let fileURL = locateFile(for: sound) else {
            throw SoundError.fileNotFound(title: sound.title)
        }
        context.fileURL = fileURL
        try await nextHandler?.handle(sound: sound, context: &context)
    }

    private func locateFile(for sound: Sound) -> URL? {
        if sound.isFromServer ?? false {
            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileUrl = documentsUrl.appendingPathComponent("\(InternalFolderNames.downloadedSounds)\(sound.id).mp3")
            guard FileManager().fileExists(atPath: fileUrl.path) else {
                return nil
            }
            return fileUrl
        } else {
            guard let path = Bundle.main.path(forResource: sound.filename, ofType: nil) else {
                return nil
            }
            return URL(fileURLWithPath: path)
        }
    }
}
