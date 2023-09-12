//
//  Song.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import Foundation

struct Song: Hashable, Codable, Identifiable, MedoContentProtocol {

    let id: String
    let title: String
    let description: String
    let genreId: String
    var genreName: String?
    let duration: Double
    let filename: String
    var dateAdded: Date?
    let isOffensive: Bool
    var isFromServer: Bool?

    init(id: String = UUID().uuidString,
         title: String,
         description: String = "",
         genreId: String,
         genreName: String?,
         duration: Double = 0,
         filename: String = "",
         dateAdded: Date = Date(),
         isOffensive: Bool = false,
         isFromServer: Bool? = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.genreId = genreId
        self.genreName = genreName
        self.duration = duration
        self.filename = filename
        self.dateAdded = dateAdded
        self.isOffensive = isOffensive
        self.isFromServer = isFromServer
    }

    func fileURL() throws -> URL {
        if isFromServer ?? false {
            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileUrl = documentsUrl.appendingPathComponent("\(InternalFolderNames.downloadedSongs)\(id).mp3")
            guard FileManager().fileExists(atPath: fileUrl.path) else {
                throw SoundError.fileNotFound
            }
            return fileUrl
        } else {
            guard let path = Bundle.main.path(forResource: self.filename, ofType: nil) else {
                throw SongError.fileNotFound
            }
            return URL(fileURLWithPath: path)
        }
    }
}

enum SongError: Error {

    case fileNotFound
}
