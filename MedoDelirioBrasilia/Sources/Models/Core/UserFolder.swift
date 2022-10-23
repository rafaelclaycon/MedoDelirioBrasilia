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
    
    init(id: String = UUID().uuidString,
         symbol: String,
         name: String,
         backgroundColor: String,
         editingIdentifyingId: String? = UUID().uuidString) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.backgroundColor = backgroundColor
        self.editingIdentifyingId = editingIdentifyingId
    }

}
