//
//  LocalDatabase+Generic.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/04/23.
//

import Foundation
import SQLite

extension LocalDatabase {
    
    func getAuthorCount() throws -> Int {
        try db.scalar(author.count)
    }
    
    func insert(author newAuthor: Author) throws {
        let insert = try author.insert(newAuthor)
        try db.run(insert)
    }
    
    func getAllAuthors() throws -> [Author] {
        var queriedAuthors = [Author]()
        for queriedAuthor in try db.prepare(author) {
            queriedAuthors.append(try queriedAuthor.decode())
        }
        return queriedAuthors
    }
}
