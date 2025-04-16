//
//  FakeContentRepository.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 15/04/25.
//

import Foundation

final class FakeContentRepository: ContentRepositoryProtocol {

    func allContent(_ allowSensitive: Bool, _ sortOrder: SoundSortOption) throws -> [AnyEquatableMedoContent] {
        []
    }
    
    func favorites(_ allowSensitive: Bool, _ sortOrder: SoundSortOption) throws -> [AnyEquatableMedoContent] {
        []
    }
    
    func songs(_ allowSensitive: Bool, _ sortOrder: SoundSortOption) throws -> [AnyEquatableMedoContent] {
        []
    }
    
    func content(by authorId: String, _ allowSensitive: Bool, _ sortOrder: SoundSortOption) throws -> [AnyEquatableMedoContent] {
        []
    }
    
    func content(in folderId: String, _ allowSensitive: Bool, _ sortOrder: FolderSoundSortOption) throws -> [AnyEquatableMedoContent] {
        []
    }

    func content(withIds contentIds: [String]) throws -> [AnyEquatableMedoContent] {
        []
    }

    func favorites() throws -> [Favorite] {
        []
    }

    func favoriteExists(_ contentId: String) throws -> Bool {
        false
    }

    func insert(favorite: Favorite) throws {
        //
    }

    func deleteFavorite(_ contentId: String) throws {
        //
    }

    func author(withId authorId: String) throws -> Author? {
        nil
    }

    func clearCache() {
        //
    }
}
