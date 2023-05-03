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
}
