//
//  ContentUpdateEnums.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/05/23.
//

import Foundation

enum MediaType: Int, Codable {
    case sound, author, song, musicGenre
}

enum EventType: Int, Codable {
    case created, metadataUpdated, fileUpdated, deleted
}

enum ContentUpdateResult {
    case nothingToUpdate, updated
}

enum ContentUpdateError: Error {

    case errorInsertingUpdateEvent(updateEventId: String)
    case updateError
}

enum ContentUpdateStatus: CustomStringConvertible {

    case updating, done, updateError, pendingFirstUpdate

    var description: String {
        switch self {
        case .updating:
            return "Atualizando..."
        case .done:
            return "Você tem as últimas novidades."
        case .updateError:
            return "Não foi possível obter as últimas novidades."
        case .pendingFirstUpdate:
            return "Primeira atualização ainda não autorizada."
        }
    }
}
