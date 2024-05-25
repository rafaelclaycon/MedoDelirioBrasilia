//
//  PushDevice.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/08/22.
//

import Foundation

struct PushDevice: Hashable, Codable {

    var installId: String
    var pushToken: String?

}
