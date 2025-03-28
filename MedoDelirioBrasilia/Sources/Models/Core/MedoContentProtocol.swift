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
    var subtitle: String { get }
    var duration: Double { get }
    var dateAdded: Date? { get }

    func fileURL() throws -> URL
}
