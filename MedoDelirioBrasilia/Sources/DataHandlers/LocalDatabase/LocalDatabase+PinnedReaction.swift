//
//  LocalDatabase+PinnedReaction.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 17/11/24.
//

import Foundation
import SQLite

private typealias Expression = SQLite.Expression

extension LocalDatabase {

    // Create

    func insert(_ pinnedReaction: Reaction) throws {
        let id = Expression<String>("id")
        let reactionId = Expression<String>("reactionId")
        let reactionTitle = Expression<String>("reactionTitle")
        let addedAt = Expression<Date>("addedAt")

        try db.run(pinnedReactionTable.insert(
            id <- UUID().uuidString,
            reactionId <- pinnedReaction.id,
            reactionTitle <- pinnedReaction.title,
            addedAt <- Date.now
        ))
    }

    // Read

    func pinnedReactions() throws -> [Reaction] {
        let addedAt = Expression<Date>("addedAt")
        let sortedQuery = try db.prepare(pinnedReactionTable.order(addedAt.asc))

        let reactionId = Expression<String>("reactionId")
        let reactionTitle = Expression<String>("reactionTitle")
        var count: Int = 0
        return sortedQuery.map { row in
            count += 1
            return Reaction(
                id: row[reactionId],
                title: row[reactionTitle],
                position: count,
                image: ""
            )
        }
    }

    // Delete

    func delete(reactionId: String) throws {
        let id = Expression<String>("reactionId")

        let pinnedReaction = pinnedReactionTable.filter(id == reactionId)
        if try db.run(pinnedReaction.delete()) == 0 {
            throw LocalDatabaseError.pinnedReactionNotFound
        }
    }
}
