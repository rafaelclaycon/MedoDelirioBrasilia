//
//  SyncTypes.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/05/23.
//

import Foundation

enum MediaType: Int, Codable {
    
    case sound, author, song
}

enum EventType: Int, Codable {
    
    case created, metadataUpdated, fileUpdated, deleted
}
