//
//  UserFolder.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import Foundation

struct UserFolder: Hashable, Codable, Identifiable {

    var id: String
    var symbol: String
    var name: String
    var backgroundColor: String
    var editingIdentifyingId: String?
    var creationDate: Date?
    var version: String?
    var userSortPreference: Int?
    
    init(
        id: String = UUID().uuidString,
        symbol: String,
        name: String,
        backgroundColor: String,
        editingIdentifyingId: String? = UUID().uuidString,
        creationDate: Date? = nil,
        version: String? = nil,
        userSortPreference: Int? = nil
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.backgroundColor = backgroundColor
        self.editingIdentifyingId = editingIdentifyingId
        self.creationDate = creationDate
        self.version = version
        self.userSortPreference = userSortPreference
    }
}

struct UserFolderDTO: Codable {

    let id: String
    let name: String
    var sounds: [String]

    init(
        id: String,
        name: String,
        sounds: [String]
    ) {
        self.id = id
        self.name = name
        self.sounds = sounds
    }

    init(
        userFolder: UserFolder
    ) {
        self.id = userFolder.id
        self.name = userFolder.name
        self.sounds = []
    }
}
