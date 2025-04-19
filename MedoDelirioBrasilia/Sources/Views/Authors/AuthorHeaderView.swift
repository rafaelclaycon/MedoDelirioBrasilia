//
//  AuthorHeaderView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 19/04/25.
//

import SwiftUI
import Kingfisher

struct AuthorHeaderView: View {

    let author: Author
    let title: String
    let soundCountText: String

    // MARK: - Computed Properties

    private func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }

    private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        // Image was pulled down
        if offset > 0 {
            return -offset
        }
        return 0
    }

    private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height
        if offset > 0 {
            return imageHeight + offset
        }
        return imageHeight
    }

    // MARK: - View Body

    var body: some View {
        VStack {
            if let photo = author.photo {
                GeometryReader { headerPhotoGeometry in
                    KFImage(URL(string: photo))
                        .placeholder {
                            Image(systemName: "photo.on.rectangle")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .foregroundColor(.gray)
                                .opacity(0.3)
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: headerPhotoGeometry.size.width,
                            height: self.getHeightForHeaderImage(headerPhotoGeometry)
                        )
                        .clipped()
                        .offset(x: 0, y: self.getOffsetForHeaderImage(headerPhotoGeometry))
                }
                .frame(height: 250)
            }

            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text(title)
                        .font(.title)
                        .bold()

                    Spacer()

                    //moreOptionsMenu(isOnToolbar: false)
                }

                if let description = author.description {
                    Text(description)
                }

                if !author.links.isEmpty {
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 10) {
                            ForEach(author.links, id: \.title) {
                                ExternalLinkButton(externalLink: $0)
                            }
                        }
                        VStack(alignment: .leading, spacing: 15) {
                            ForEach(author.links, id: \.title) {
                                ExternalLinkButton(externalLink: $0)
                            }
                        }
                    }
                    .padding(.vertical, .spacing(.xxxSmall))
                }

                Text(soundCountText)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .bold()
            }
            .padding(.horizontal, .spacing(.large))
            .padding(.top, .spacing(.small))
            .padding(.bottom, .spacing(.xxSmall))
        }
    }
}

// MARK: - Preview

#Preview {
    let author = Author(id: "abc", name: "Atila Iamarino")

    return AuthorHeaderView(
        author: author,
        title: author.name,
        soundCountText: "10 SONS"
    )
}
