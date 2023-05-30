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
    
    func allAuthors() throws -> [Author] {
        var queriedAuthors = [Author]()
        for queriedAuthor in try db.prepare(author) {
            queriedAuthors.append(try queriedAuthor.decode())
        }
        return queriedAuthors
    }
    
    func author(withId authorId: String) throws -> Author? {
        var queriedItems = [Author]()
        let id = Expression<String>("id")
        let query = author.filter(id == authorId)
        for queriedItem in try db.prepare(query) {
            queriedItems.append(try queriedItem.decode())
        }
        return queriedItems.first
    }
}
