//
//  ShareHandler.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 15/11/24.
//

import Foundation

protocol ShareHandler {

    var nextHandler: ShareHandler? { get set }
    func handle(sound: Sound, context: inout ShareContext) async throws
}

struct ShareContext {

    var fileURL: URL?
    var renamedFileName: String?
    var sharedAppBundleId: String?
    var isShareSuccessful: Bool = false
}
