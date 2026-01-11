//
//  PlayableContentStateTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 04/01/26.
//

import Testing
@testable import MedoDelirio
import SwiftUI

struct PlayableContentStateTests {

    @Test func loadFavorites_whenRepositoryHasFavorites_shouldPopulateFavoritesKeeper() async throws {
        let repo = FakeContentRepository()
        repo.fakeFavorites = [
            Favorite(contentId: "sound-1", dateAdded: Date()),
            Favorite(contentId: "sound-2", dateAdded: Date())
        ]

        let sut = await PlayableContentState(
            contentRepository: repo,
            contentFileManager: FakeContentFileManager(),
            analyticsService: FakeAnalyticsService(),
            screen: .mainContentView,
            toast: .constant(nil)
        )

        #expect(await sut.favoritesKeeper.count == 2)
        #expect(await sut.favoritesKeeper.contains("sound-1"))
        #expect(await sut.favoritesKeeper.contains("sound-2"))
    }

    @Test func toggleFavorite_whenNotFavorited_shouldAddToFavorites() async throws {
        let repo = FakeContentRepository()

        let sut = await PlayableContentState(
            contentRepository: repo,
            contentFileManager: FakeContentFileManager(),
            analyticsService: FakeAnalyticsService(),
            screen: .mainContentView,
            toast: .constant(nil)
        )

        await sut.toggleFavorite("sound-1")

        #expect(await sut.favoritesKeeper.contains("sound-1"))
    }

    @Test func toggleFavorite_whenAlreadyFavorited_shouldRemoveFromFavorites() async throws {
        let repo = FakeContentRepository()
        repo.fakeFavorites = [Favorite(contentId: "sound-1", dateAdded: Date())]

        let sut = await PlayableContentState(
            contentRepository: repo,
            contentFileManager: FakeContentFileManager(),
            analyticsService: FakeAnalyticsService(),
            screen: .mainContentView,
            toast: .constant(nil)
        )

        await sut.toggleFavorite("sound-1")

        #expect(await sut.favoritesKeeper.contains("sound-1") == false)
    }

    @Test func openShareAsVideoModal_shouldSetActiveSheet() async throws {
        let sut = await PlayableContentState(
            contentRepository: FakeContentRepository(),
            contentFileManager: FakeContentFileManager(),
            analyticsService: FakeAnalyticsService(),
            screen: .mainContentView,
            toast: .constant(nil)
        )

        let content = AnyEquatableMedoContent(Sound(title: "Test Sound"))
        await sut.openShareAsVideoModal(for: content)

        let activeSheet = await sut.activeSheet
        #expect(activeSheet != nil)
        if case .shareAsVideo(let sheetContent) = activeSheet {
            #expect(sheetContent.id == content.id)
        } else {
            Issue.record("Expected shareAsVideo sheet")
        }
    }

    @Test func addToFolder_shouldSetActiveSheetAndSelectedContent() async throws {
        let sut = await PlayableContentState(
            contentRepository: FakeContentRepository(),
            contentFileManager: FakeContentFileManager(),
            analyticsService: FakeAnalyticsService(),
            screen: .mainContentView,
            toast: .constant(nil)
        )

        let content = AnyEquatableMedoContent(Sound(title: "Test Sound"))
        await sut.addToFolder(content)

        let selectedMultiple = await sut.selectedContentMultiple
        #expect(selectedMultiple?.count == 1)
        #expect(selectedMultiple?.first?.id == content.id)

        let activeSheet = await sut.activeSheet
        if case .addToFolder(let contents) = activeSheet {
            #expect(contents.count == 1)
        } else {
            Issue.record("Expected addToFolder sheet")
        }
    }

    @Test func showDetails_shouldSetActiveSheetAndSelectedContent() async throws {
        let sut = await PlayableContentState(
            contentRepository: FakeContentRepository(),
            contentFileManager: FakeContentFileManager(),
            analyticsService: FakeAnalyticsService(),
            screen: .mainContentView,
            toast: .constant(nil)
        )

        let content = AnyEquatableMedoContent(Sound(title: "Test Sound"))
        await sut.showDetails(for: content)

        let selected = await sut.selectedContent
        #expect(selected?.id == content.id)

        let activeSheet = await sut.activeSheet
        if case .contentDetail(let sheetContent) = activeSheet {
            #expect(sheetContent.id == content.id)
        } else {
            Issue.record("Expected contentDetail sheet")
        }
    }
}

