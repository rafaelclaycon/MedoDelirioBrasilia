//
//  FakeAuthorService.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/04/25.
//

import Foundation

class FakeAuthorService: AuthorServiceProtocol {

    func allAuthors(_ sortOrder: AuthorSortOption) throws -> [Author] {
        []
    }

    func authors(matchingName name: String) -> [Author]? {
        nil
    }
}
