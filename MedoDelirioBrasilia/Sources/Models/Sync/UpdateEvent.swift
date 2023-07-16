//
//  UpdateEvent.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/05/23.
//

import Foundation

struct UpdateEvent: Hashable, Codable, Identifiable {
    
    let id: UUID
    let contentId: String
    let dateTime: String
    let mediaType: MediaType
    let eventType: EventType
    var didSucceed: Bool?

    init(
        id: UUID = UUID(),
        contentId: String,
        dateTime: String = Date.now.iso8601withFractionalSeconds,
        mediaType: MediaType,
        eventType: EventType,
        didSucceed: Bool? = nil
    ) {
        self.id = id
        self.contentId = contentId
        self.dateTime = dateTime
        self.mediaType = mediaType
        self.eventType = eventType
        self.didSucceed = didSucceed
    }
}
