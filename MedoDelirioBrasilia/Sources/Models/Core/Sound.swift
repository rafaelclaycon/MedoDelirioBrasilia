//
//  Sound.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import Foundation

struct Sound: Hashable, Codable, Identifiable {

    var id: String
    var title: String
    var authorId: String
    var authorName: String?
    var description: String
    var filename: String
    var dateAdded: Date?
    let duration: Double
    let isOffensive: Bool
    let isNew: Bool?
    let isFromServer: Bool?
    
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
        isNew: Bool? = nil,
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
        self.isNew = isNew
        self.isFromServer = isFromServer
    }
    
    func fileURL() throws -> URL {
        if isFromServer ?? false {
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileUrl = documentsUrl.appendingPathComponent("\(id).mp3")
            guard FileManager().fileExists(atPath: fileUrl.path) else {
                throw SoundError.fileNotFound
            }
            return fileUrl
        } else {
            guard let path = Bundle.main.path(forResource: self.filename, ofType: nil) else {
                throw SoundError.fileNotFound
            }
            return URL(fileURLWithPath: path)
        }
    }
}

enum SoundError: Error {

    case fileNotFound
}
