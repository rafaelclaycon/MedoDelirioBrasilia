//
//  SyncService+Author.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 23/05/23.
//

import Foundation

extension SyncService {

    func createAuthor(from updateEvent: UpdateEvent) async {
        let url = URL(string: NetworkRabbit.shared.serverPath + "v3/author/\(updateEvent.contentId)")!
        do {
            let author: Author = try await NetworkRabbit.shared.get(from: url)

            try injectedDatabase.insert(author: author)
            
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Autor(a) \"\(author.name)\" criado(a) com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func updateAuthorMetadata(with updateEvent: UpdateEvent) async {
        let url = URL(string: NetworkRabbit.shared.serverPath + "v3/author/\(updateEvent.contentId)")!
        do {
            let author: Author = try await NetworkRabbit.shared.get(from: url)
            try injectedDatabase.update(author: author)
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Metadados do(a) Autor(a) \"\(author.name)\" atualizados com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func deleteAuthor(with updateEvent: UpdateEvent) async {
        do {
            try injectedDatabase.delete(authorId: updateEvent.contentId)
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Autor(a) \"\(updateEvent.contentId)\" removido(a) com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }
}
