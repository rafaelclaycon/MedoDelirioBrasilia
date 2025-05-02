//
//  Sound.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import Foundation

struct Sound: Hashable, Codable, Identifiable, MedoContentProtocol {

    let id: String
    let title: String
    let authorId: String
    var authorName: String?
    let description: String
    let filename: String
    var dateAdded: Date?
    let duration: Double
    let isOffensive: Bool
    var isFromServer: Bool?

    init(
        id: String = UUID().uuidString,
        title: String,
        authorId: String = UUID().uuidString,
        authorName: String? = nil,
        description: String = "",
        filename: String = "",
        dateAdded: Date? = Date(),
        duration: Double = 0,
        isOffensive: Bool = false,
        isFromServer: Bool? = false
    ) {
        self.id = id
        self.title = title
        self.authorId = authorId
        self.authorName = authorName
        self.description = description
        self.filename = filename
        self.dateAdded = dateAdded
        self.duration = duration
        self.isOffensive = isOffensive
        self.isFromServer = isFromServer
    }

    var subtitle: String {
        authorName ?? ""
    }

    var type: MediaType {
        .sound
    }

    func fileURL() throws -> URL {
        if isFromServer ?? false {
            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileUrl = documentsUrl.appendingPathComponent("\(InternalFolderNames.downloadedSounds)\(id).mp3")
            guard FileManager().fileExists(atPath: fileUrl.path) else {
                throw SoundError.fileNotFound(title: self.title)
            }
            return fileUrl
        } else {
            guard let path = Bundle.main.path(forResource: self.filename, ofType: nil) else {
                throw SoundError.fileNotFound(title: self.title)
            }
            return URL(fileURLWithPath: path)
        }
    }
}

enum SoundError: Error, LocalizedError {

    case fileNotFound(title: String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let soundTitle):
            return "O arquivo do som \"\(soundTitle)\" não foi encontrado."
        }
    }
}

extension Sound {

    static let sampleSounds = [
        Sound(title: "Alegria", authorName: "Fábio Porchat"),
        Sound(title: "Maravilhoso!", authorName: "Milton Cunha"),
        Sound(title: "Cadê os machos?", authorName: "Michelle Bolsonaro"),
        Sound(title: "Popcorn and ice cream sellers", authorName: "Jair Bolsonaro"),
        Sound(title: "O que é que é dura?", authorName: "Jair Bolsonaro"),
        Sound(title: "Lixo, arrombado", authorName: "Soraya Thronicke")
    ]
}
