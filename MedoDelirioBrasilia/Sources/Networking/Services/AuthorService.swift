//
//  AuthorService.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/04/25.
//

import Foundation

protocol AuthorServiceProtocol {

    func allAuthors(_ sortOrder: AuthorSortOption) throws -> [Author]
}

final class AuthorService: AuthorServiceProtocol {

    private let database: LocalDatabaseProtocol

    private var allAuthors: [Author]?

    // MARK: - Initializer

    init(
        database: LocalDatabaseProtocol
    ) {
        self.database = database
        self.allAuthors = []
        loadAllAuthors()
    }

    // MARK: - Functions

    func allAuthors(_ sortOrder: AuthorSortOption) throws -> [Author] {
        guard let allAuthors, allAuthors.count > 0 else { return [] }
        return sort(authors: allAuthors, by: sortOrder)
    }
}

// MARK: - Internal Functions

extension AuthorService {

    private func loadAllAuthors() {
        do {
            allAuthors = try database.allAuthors()
        } catch {
            debugPrint(error)
        }
    }

    private func sort(authors: [Author], by sortOption: AuthorSortOption) -> [Author] {
        switch sortOption {
        case .nameAscending:
            authors.sorted(by: { $0.name.withoutDiacritics() < $1.name.withoutDiacritics() })
        case .soundCountDescending:
            authors.sorted(by: { $0.soundCount ?? 0 > $1.soundCount ?? 0 })
        case .soundCountAscending:
            authors.sorted(by: { $0.soundCount ?? 0 < $1.soundCount ?? 0 })
        }
    }
}
