//
//  LocalDatabase+Generic.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/04/23.
//

import Foundation
import SQLite

private typealias Expression = SQLite.Expression

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
        let author_id = Expression<String>("authorId")

        for queriedAuthor in try db.prepare(author) {
            var author: Author = try queriedAuthor.decode()
            let soundsCount = try db.scalar(soundTable.filter(author_id == author.id).count)
            author.soundCount = soundsCount
            queriedAuthors.append(author)
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
    
    func update(author updatedAuthor: Author) throws {
        let id = Expression<String>("id")
        let query = author.filter(id == updatedAuthor.id)
        let updateQuery = query.update(
            Expression<String>("name") <- updatedAuthor.name,
            Expression<String?>("photo") <- updatedAuthor.photo,
            Expression<String?>("description") <- updatedAuthor.description,
            Expression<String?>("externalLinks") <- updatedAuthor.externalLinks
        )
        try db.run(updateQuery)
    }

    func delete(authorId: String) throws {
        let id = Expression<String>("id")

        let query = author.filter(id == authorId)
        let count = try db.scalar(query.count)

        if count != 0 {
            try db.run(query.delete())
        } else {
            throw LocalDatabaseError.authorNotFound
        }
    }

    func authorPhoto(for soundId: String) throws -> String? {
        let soundIdColumn = Expression<String>("id")
        let authorId = Expression<String>("authorId")
        let authorIdColumn = Expression<String>("id")
        let authorPhoto = Expression<String?>("photo")

        guard let row = try db.pluck(soundTable.filter(soundIdColumn == soundId)) else {
            return nil
        }

        let foundAuthorId = row[authorId]

        guard let authorRow = try db.pluck(author.filter(authorIdColumn == foundAuthorId)) else {
            return nil
        }

        return authorRow[authorPhoto]
    }
}
