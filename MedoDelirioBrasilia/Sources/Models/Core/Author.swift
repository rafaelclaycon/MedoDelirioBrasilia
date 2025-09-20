//
//  Author.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 20/05/22.
//

import Foundation

public struct Author: Hashable, Codable, Identifiable {

    public let id: String
    let name: String
    let photo: String?
    let description: String?
    var soundCount: Int?
    var externalLinks: String?

    init(
        id: String,
        name: String,
        photo: String? = nil,
        description: String? = nil,
        soundCount: Int? = nil,
        externalLinks: String? = nil
    ) {
        self.id = id
        self.name = name
        self.photo = photo
        self.description = description
        self.soundCount = soundCount
        self.externalLinks = externalLinks
    }

    var links: [ExternalLink] {
        guard let links = self.externalLinks else {
            return []
        }
        guard let jsonData = links.data(using: .utf8) else {
            return []
        }
        let decoder = JSONDecoder()
        do {
            let decodedLinks = try decoder.decode([ExternalLink].self, from: jsonData)
            return decodedLinks
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }
}
