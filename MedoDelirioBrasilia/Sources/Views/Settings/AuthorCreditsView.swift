//
//  AuthorCreditsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 07/07/25.
//

import SwiftUI

struct AuthorCreditsView: View {

    private let links: [AuthorSectionLink] = [
        AuthorSectionLink(
            name: "Blogue", imageName: "book", link: "https://from-rafael-with-code.ghost.io/", color: .pink, type: .blog
        ),
        AuthorSectionLink(
            name: "Mastodon", imageName: "mastodon", link: "https://burnthis.town/@rafael", color: .purple, type: .socialMedia
        ),
        AuthorSectionLink(
            name: "Bluesky", imageName: "bluesky", link: "https://bsky.app/profile/rafaelschmitt.bsky.social", color: .blue, type: .socialMedia
        )
    ]

    @ScaledMetric private var iconWidth: CGFloat = 20.0

    var body: some View {
        VStack(alignment: .center, spacing: .spacing(.large)) {
            Text("Criado por Rafael Schmitt")
                .font(.system(.headline, design: .rounded))
                .multilineTextAlignment(.center)

            HStack(spacing: .spacing(.medium)) {
                Spacer()

                ForEach(links) { link in
                    Button {
                        Task {
                            OpenUtility.open(link: link.link)

                            switch link.type {
                            case .blog:
                                await sendAnalytics(for: "didTapBlogLink")
                            case .socialMedia:
                                await sendAnalytics(for: "didTapSocialLink(\(link.name))")
                            }
                        }
                    } label: {
                        if link.type == .blog {
                            Image(systemName: link.imageName)
                                .bold()
                                .foregroundColor(link.color)
                        } else {
                            Image(link.imageName)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconWidth)
                                .foregroundColor(link.color)
                        }
                    }
                    .borderedButton(colored: link.color)
                }

                Spacer()
            }
        }
    }

    private func sendAnalytics(for action: String) async {
        await AnalyticsService().send(
            originatingScreen: "SettingsView",
            action: action
        )
    }
}

#Preview {
    Form {
        Section {
            AuthorCreditsView()
        }
    }
}
