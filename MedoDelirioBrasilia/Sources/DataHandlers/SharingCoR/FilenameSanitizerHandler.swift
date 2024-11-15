//
//  FilenameSanitizerHandler.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 15/11/24.
//

import Foundation

final class FilenameSanitizerHandler: ShareHandler {

    var nextHandler: ShareHandler?

    func handle(sound: Sound, context: inout ShareContext) async throws {
        guard let fileURL = context.fileURL else { throw NSError(domain: "FilenameSanitizer", code: 500, userInfo: nil) }
        let sanitizedFilename = sanitizeFilename(for: sound.title)
        let newURL = fileURL.deletingLastPathComponent().appendingPathComponent(sanitizedFilename)
        try FileManager.default.moveItem(at: fileURL, to: newURL)
        context.fileURL = newURL
        context.renamedFileName = sanitizedFilename
        try await nextHandler?.handle(sound: sound, context: &context)
    }

    private func sanitizeFilename(for title: String) -> String {
        // Remove `?`, `!`, and emojis while keeping spaces
        let regex = try! NSRegularExpression(pattern: "[?!]|[\\p{Emoji}]", options: .caseInsensitive)
        var sanitized = regex.stringByReplacingMatches(in: title, options: [], range: NSRange(location: 0, length: title.utf16.count), withTemplate: "")

        // Replace accented characters with their unaccented counterparts
        let transform = StringTransform("Any-Latin; Latin-ASCII; [:Nonspacing Mark:] Remove")
        sanitized = sanitized.applyingTransform(transform, reverse: false) ?? sanitized

        return sanitized
    }
}
