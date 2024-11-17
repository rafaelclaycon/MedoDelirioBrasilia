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
        try db.run(pinnedReactionTable.insert(pinnedReaction))
    }

    // Read

    func pinnedReactions() throws -> [Reaction] {
        let addedAt = Expression<Date>("addedAt")
        let sortedQuery = try db.prepare(pinnedReactionTable.order(addedAt.asc))

        let reactionId = Expression<String>("reactionId")
        let reactionName = Expression<String>("reactionName")
        var count: Int = 0
        return sortedQuery.map { row in
            count += 1
            return Reaction(
                id: row[reactionId],
                title: row[reactionName],
                position: count,
                image: ""
            )
        }
    }

    // Delete

    func delete(_ reactionId: String) throws {
        let id = Expression<String>("reactionId")

        let pinnedReaction = pinnedReactionTable.filter(id == reactionId)
        if try db.run(pinnedReaction.delete()) == 0 {
            throw LocalDatabaseError.pinnedReactionNotFound
        }
    }
}
