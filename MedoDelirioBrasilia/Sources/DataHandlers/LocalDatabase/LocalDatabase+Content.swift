//
//  LocalDatabase+Content.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 16/04/25.
//

import Foundation
import SQLite

private typealias Expression = SQLite.Expression

extension LocalDatabase {
    
    func content(withIds contentIds: [String]) throws -> [AnyEquatableMedoContent] {
        let sounds = try self.sounds(withIds: contentIds).map { AnyEquatableMedoContent($0) }
        let songs = try self.songs(withIds: contentIds).map { AnyEquatableMedoContent($0) }
        return sounds + songs
    }
}
