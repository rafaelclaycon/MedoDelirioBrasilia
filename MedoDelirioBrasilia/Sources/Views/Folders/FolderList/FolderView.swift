//
//  FolderView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct FolderView: View {

    let folder: UserFolder

    @State var height: CGFloat = 90

    var body: some View {
        VStack(spacing: .spacing(.xSmall)) {
            FolderIcon(
                color: folder.backgroundColor.toPastelColor(),
                emoji: folder.symbol,
                isEmpty: folder.isEmpty
            )

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(folder.name)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(.leading, .spacing(.medium))
        }
    }
}

// MARK: - Subviews

extension FolderView {

    struct FolderIcon: View {

        let color: Color
        let emoji: String
        let isEmpty: Bool

        var body: some View {
            VStack {
                Spacer()
                    .frame(height: 18)

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(color)
                    .frame(height: 106)
                    .overlay { SpeckleOverlay() }
            }
            .background(alignment: .topLeading) {
                HStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(color)
                        .frame(width: 60, height: 100)
                        .overlay { SpeckleOverlay() }

                    Spacer()
                }
            }
            .overlay(alignment: .top) {
                if !isEmpty {
                    VStack {
                        Spacer()
                            .frame(height: 22)
                        
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white)
                            .frame(height: 50)
                            .shadow(radius: 1)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(color)
                    .frame(height: 95)
                    .overlay { SpeckleOverlay() }
                    .padding(.horizontal, .spacing(.nano))
                    .modifier(PerspectiveModifier())
                    .shadow(radius: 3, y: -1)
                    .overlay(alignment: .topLeading) {
                        Text(emoji)
                            .font(.system(size: 38))
                            .padding(.leading, 16)
                            .padding(.top, 8)
                    }
                    .offset(y: 3)
            }
            .padding(.horizontal, .spacing(.nano))
        }
    }

    struct SpeckleOverlay: View {

        var body: some View {
            Canvas { context, size in
                for _ in 0..<200 {
                    let x = CGFloat.random(in: 0..<size.width)
                    let y = CGFloat.random(in: 0..<size.height)
                    let diameter = CGFloat.random(in: 0.5...1.9)
                    let rect = CGRect(x: x, y: y, width: diameter, height: diameter)
                    context.fill(Path(ellipseIn: rect), with: .color(.black.opacity(0.1)))
                }
            }
        }
    }
}

struct PerspectiveModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(10),
                axis: (x: -1.0, y: 0.0, z: 0.0),
                anchor: .center,
                anchorZ: 0,
                perspective: 1
            )
    }
}

// MARK: - Preview

#Preview {
    let columns = [
        GridItem(.flexible(), spacing: 22),
        GridItem(.flexible(), spacing: 22)
    ]

    let folders = [
        UserFolder(
            symbol: "🤡",
            name: "Uso diario",
            backgroundColor: "pastelPurple",
            contentCount: 3
        ),
        UserFolder(
            symbol: "😅",
            name: "Meh",
            backgroundColor: "pastelPurple",
            contentCount: 3
        ),
        UserFolder(
            symbol: "🏙️",
            name: "Política",
            backgroundColor: "pastelPurple",
            contentCount: 0
        ),
        UserFolder(
            symbol: "🙅🏿‍♂️",
            name: "Anti-Racista",
            backgroundColor: "pastelRoyalBlue",
            contentCount: 3
        ),
        UserFolder(
            symbol: "✋",
            name: "Espera!",
            backgroundColor: "pastelPurple",
            contentCount: 3
        ),
        UserFolder(
            symbol: "🔥",
            name: "Queima!",
            backgroundColor: "pastelPurple",
            contentCount: 3
        )
    ]

    return LazyVGrid(columns: columns) {
        ForEach(folders) { folder in
            FolderView(folder: folder)
                .padding(.vertical, 6)
        }
    }
    .padding(.horizontal, .spacing(.medium))
}
