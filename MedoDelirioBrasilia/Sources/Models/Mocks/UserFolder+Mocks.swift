//
//  UserFolder+Mocks.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 01/11/24.
//

import Foundation

extension UserFolder {

    static var mockA: UserFolder {
        .init(
            id: "E69BD85E-F196-4F53-8509-2A70EDF1B833",
            symbol: "🧪",
            name: "Memes",
            backgroundColor: "pastelBabyBlue"
        )
    }

    static var mockB: UserFolder {
        .init(
            id: "DD9C09AD-9167-4FB4-85D8-700240663449",
            symbol: "😡",
            name: "Xingar",
            backgroundColor: "pastelPurple"
        )
    }

    static var mockC: UserFolder {
        .init(
            id: "409440AF-A2CA-4126-9AF2-68FD98184547",
            symbol: "🫏",
            name: "Bozo",
            backgroundColor: "pastelPurple"
        )
    }
}
