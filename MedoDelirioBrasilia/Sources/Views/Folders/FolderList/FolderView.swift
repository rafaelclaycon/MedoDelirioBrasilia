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
        VStack(spacing: .spacing(.xxSmall)) {
            FolderSymbol(
                color: folder.backgroundColor.toPastelColor(),
                emoji: folder.symbol
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

    struct FolderSymbol: View {

        let color: Color
        let emoji: String

        var body: some View {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(color)
                .frame(height: 105)
                .overlay { SpeckleOverlay() }
                .padding(.horizontal, .spacing(.nano))
                .modifier(PerspectiveModifier())
                .overlay(alignment: .topLeading) {
                    Text(emoji)
                        .font(.system(size: 38))
                        .padding()
                }
        }
    }

    struct PerspectiveRectangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()

            // Define the amount of perspective distortion
            let perspectiveOffset: CGFloat = rect.height * 0.2

            // Define the four corners of the quadrilateral
            let topLeft = CGPoint(x: rect.minX, y: rect.minY)
            let topRight = CGPoint(x: rect.maxX, y: rect.minY)
            let bottomRight = CGPoint(x: rect.maxX - perspectiveOffset, y: rect.maxY)
            let bottomLeft = CGPoint(x: rect.minX + perspectiveOffset, y: rect.maxY)

            // Draw the path
            path.move(to: topLeft)
            path.addLine(to: topRight)
            path.addLine(to: bottomRight)
            path.addLine(to: bottomLeft)
            path.closeSubpath()

            return path
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
        GridItem(.flexible(), spacing: .spacing(.large)),
        GridItem(.flexible(), spacing: .spacing(.large))
    ]

    let folders = [
        UserFolder(symbol: "🤡", name: "Uso diario", backgroundColor: "pastelPurple"),
        UserFolder(symbol: "😅", name: "Meh", backgroundColor: "pastelPurple"),
        UserFolder(symbol: "🏙️", name: "Política", backgroundColor: "pastelPurple"),
        UserFolder(symbol: "🙅🏿‍♂️", name: "Anti-Racista", backgroundColor: "pastelRoyalBlue")
    ]

    return LazyVGrid(columns: columns) {
        ForEach(folders) { folder in
            FolderView(folder: folder)
        }
    }
    .padding()
}
