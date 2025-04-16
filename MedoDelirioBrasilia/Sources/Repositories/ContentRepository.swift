//
//  ContentRepository.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/04/25.
//

import Foundation

protocol ContentRepositoryProtocol {

    func allContent(_ allowSensitive: Bool, _ sortOrder: SoundSortOption) throws -> [AnyEquatableMedoContent]
    func favorites(_ allowSensitive: Bool, _ sortOrder: SoundSortOption) throws -> [AnyEquatableMedoContent]
    func songs(_ allowSensitive: Bool, _ sortOrder: SoundSortOption) throws -> [AnyEquatableMedoContent]

    func content(by authorId: String, _ allowSensitive: Bool, _ sortOrder: SoundSortOption) throws -> [AnyEquatableMedoContent]
    func content(in folderId: String, _ allowSensitive: Bool, _ sortOrder: SoundSortOption) throws -> [AnyEquatableMedoContent]
    func reactionContent(reactionId: String, _ allowSensitive: Bool, _ sortOrder: SoundSortOption) throws -> [AnyEquatableMedoContent]
}

final class ContentRepository: ContentRepositoryProtocol {

    private let database: LocalDatabase

    private var allContent: [AnyEquatableMedoContent]

    // MARK: - Initializer

    init(
        database: LocalDatabase = LocalDatabase()
    ) {
        self.database = database
        self.allContent = []
        loadAllContent()
    }

    func allContent(_ allowSensitive: Bool, _ sortOrder: SoundSortOption) throws -> [AnyEquatableMedoContent] {
        guard allContent.count > 0 else { return [] }
        var content = allContent
        if !allowSensitive {
            content = content.filter { !$0.isOffensive }
        }
        return sort(content: content, by: sortOrder)
    }

    func favorites(_ allowSensitive: Bool, _ sortOrder: SoundSortOption) throws -> [AnyEquatableMedoContent] {
        guard allContent.count > 0 else { return [] }
        let favorites = try database.favorites().map { $0.contentId }
        var content = allContent.filter { favorites.contains($0.id) }
        if !allowSensitive {
            content = content.filter { !$0.isOffensive }
        }
        return sort(content: content, by: sortOrder)
    }

    func songs(_ allowSensitive: Bool, _ sortOrder: SoundSortOption) throws -> [AnyEquatableMedoContent] {
        guard allContent.count > 0 else { return [] }
        var content = allContent.filter { $0.type == .song }
        if !allowSensitive {
            content = content.filter { !$0.isOffensive }
        }
        return sort(content: content, by: sortOrder)
    }

    func content(by authorId: String, _ allowSensitive: Bool, _ sortOrder: SoundSortOption) throws -> [AnyEquatableMedoContent] {
        guard allContent.count > 0 else { return [] }
        var content = allContent.filter { $0.authorId == authorId }
        if !allowSensitive {
            content = content.filter { !$0.isOffensive }
        }
        return sort(content: content, by: sortOrder)
    }

    func content(in folderId: String, _ allowSensitive: Bool, _ sortOrder: SoundSortOption) throws -> [AnyEquatableMedoContent] {
        []
    }

    func reactionContent(reactionId: String, _ allowSensitive: Bool, _ sortOrder: SoundSortOption) throws -> [AnyEquatableMedoContent] {
        []
    }
}

extension ContentRepository {

    private func loadAllContent() {
        do {
            let sounds: [AnyEquatableMedoContent] = try database.sounds(
                allowSensitive: true
            ).map { AnyEquatableMedoContent($0) }
            let songs: [AnyEquatableMedoContent] = try database.songs(
                allowSensitive: true
            ).map { AnyEquatableMedoContent($0) }

            allContent = sounds + songs
        } catch {
            debugPrint(error)
        }
    }

    private func sort(content: [AnyEquatableMedoContent], by sortOption: SoundSortOption) -> [AnyEquatableMedoContent] {
        switch sortOption {
        case .titleAscending:
            content.sorted(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
        case .authorNameAscending:
            content.sorted(by: { $0.subtitle.withoutDiacritics() < $1.subtitle.withoutDiacritics() })
        case .dateAddedDescending:
            content.sorted(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
        case .shortestFirst:
            content.sorted(by: { $0.duration < $1.duration })
        case .longestFirst:
            content.sorted(by: { $0.duration > $1.duration })
        case .longestTitleFirst:
            content.sorted(by: { $0.title.count > $1.title.count })
        case .shortestTitleFirst:
            content.sorted(by: { $0.title.count < $1.title.count })
        }
    }
}
