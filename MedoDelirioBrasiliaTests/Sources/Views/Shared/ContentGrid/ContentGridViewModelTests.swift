//
//  ContentGridViewModelTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 16/04/25.
//

import Testing
@testable import MedoDelirio
import SwiftUI

struct ContentGridViewModelTests {

    @Test func whenMultiSelectModeSelected_shouldEnterIt() async throws {
        var listModeValue: ContentGridMode = .regular
        let listMode = Binding<ContentGridMode>(
            get: { listModeValue },
            set: { listModeValue = $0 }
        )

        let sut = await ContentGridViewModel(
            contentRepository: FakeContentRepository(),
            searchService: FakeSearchService(),
            userFolderRepository: FakeUserFolderRepository(),
            screen: .mainContentView,
            menuOptions: [],
            currentListMode: listMode,
            toast: .constant(nil),
            floatingOptions: .constant(nil),
            analyticsService: FakeAnalyticsService()
        )

        await sut.onEnterMultiSelectModeSelected(loadedContent: [], isFavoritesOnlyView: false)

        #expect(listModeValue == .selection)
        #expect(await sut.currentListMode.wrappedValue == .selection)
    }
}
