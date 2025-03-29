//
//  AnyEquatableMedoContent.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/03/25.
//

import Foundation

struct AnyEquatableMedoContent: MedoContentProtocol, Equatable, Identifiable {

    private let base: any MedoContentProtocol
    private let isEqualFunc: (any MedoContentProtocol) -> Bool

    init<T: MedoContentProtocol & Equatable>(_ base: T) {
        self.base = base
        self.isEqualFunc = { other in
            guard let otherTyped = other as? T else { return false }
            return base == otherTyped
        }
    }

    var id: String {
        base.id
    }

    var title: String {
        base.title
    }

    var subtitle: String {
        base.subtitle
    }

    var description: String {
        base.description
    }

    var duration: Double {
        base.duration
    }

    var dateAdded: Date? {
        base.dateAdded
    }

    var isFromServer: Bool? {
        base.isFromServer
    }

    func fileURL() throws -> URL {
        try base.fileURL()
    }

    static func == (lhs: AnyEquatableMedoContent, rhs: AnyEquatableMedoContent) -> Bool {
        lhs.isEqualFunc(rhs.base)
    }
}
