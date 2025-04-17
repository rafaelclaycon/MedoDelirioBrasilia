//
//  ContentListDisplaying.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 16/04/24.
//

import SwiftUI

/// This protocol exists to enable the communication between ContextMenuOption and ContentGrid.
protocol ContentListDisplaying {

    func share(content: AnyEquatableMedoContent)

    func openShareAsVideoModal(for content: AnyEquatableMedoContent)

    func toggleFavorite(_ contentId: String)

    func addToFolder(_ content: AnyEquatableMedoContent)

    func playFrom(content: AnyEquatableMedoContent, loadedContent: [AnyEquatableMedoContent])

    func removeFromFolder(_ content: AnyEquatableMedoContent)

    func showDetails(for content: AnyEquatableMedoContent)

    func showAuthor(withId authorId: String)

    func suggestOtherAuthorName(for content: AnyEquatableMedoContent)
}
