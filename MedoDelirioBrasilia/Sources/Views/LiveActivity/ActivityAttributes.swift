//
//  ActivityAttributes.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 05/12/23.
//

import ActivityKit

//public protocol ActivityAttributes: Decodable, Encodable {
//
//    /// The associated type that describes the dynamic content of a Live Activity.
//    ///
//    /// The dynamic data of a Live Activity that's encoded by `ContentState` can't exceed 4KB.
//    associatedtype ContentState: Decodable, Encodable, Hashable
//}

struct SyncAttributes: ActivityAttributes {

    struct ContentState: Codable, Hashable {

        let status: SyncUIStatus
    }

    let updateQuantity: Int
}
