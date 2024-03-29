//
//  MedoContentProtocol.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 15/09/23.
//

import Foundation

internal protocol MedoContentProtocol {

    var id: String { get }
    var title: String { get }

    func fileURL() throws -> URL
}
