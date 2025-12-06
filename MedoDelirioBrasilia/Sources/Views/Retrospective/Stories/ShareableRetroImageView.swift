//
//  ShareableRetroImageView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 06/12/25.
//

import SwiftUI

/// A view that generates a shareable retrospective summary image
/// Uses a base template image with dynamic data overlaid
struct ShareableRetroImageView: View {
    
    let authorPhoto: UIImage?
    let topSounds: [TopChartItem]
    let totalShares: Int
    let favoriteDay: String
    
    // Template dimensions (adjust based on your actual template)
    private let templateWidth: CGFloat = 828
    private let templateHeight: CGFloat = 1472
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Base template image
            Image("retro2025ShareTemplate")
                .resizable()
                .frame(width: templateWidth, height: templateHeight)
            
            // Author photo - fixed position
            authorPhotoView
                .offset(x: 62, y: 52)
            
            // Top sounds list - fixed position
            soundsListView
                .offset(x: 62, y: 786)
            
            // Total shares stat - fixed position
            totalSharesView
                .offset(x: 62, y: 1142)
            
            // Favorite day stat - fixed position (independent of total shares width)
            favoriteDayView
                .offset(x: 435, y: 1152)
        }
        .frame(width: templateWidth, height: templateHeight)
    }
    
    // MARK: - Subviews
    
    private var authorPhotoView: some View {
        Group {
            if let photo = authorPhoto {
                Image(uiImage: photo)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 500, height: 470)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 500, height: 470)
            }
        }
    }
    
    private var soundsListView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(topSounds.prefix(5).enumerated()), id: \.offset) { index, sound in
                Text("\(index + 1) \(sound.contentName)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color(hex: "1a1a1a"))
                    .lineLimit(1)
            }
        }
    }
    
    private var totalSharesView: some View {
        Text("\(totalShares)")
            .font(.system(size: 72, weight: .bold))
            .foregroundStyle(Color.darkestGreen.opacity(0.7))
    }
    
    private var favoriteDayView: some View {
        Text(favoriteDay)
            .font(.system(size: 48, weight: .bold))
            .foregroundStyle(Color.darkestGreen.opacity(0.7))
    }
}

// MARK: - Image Generation

extension ShareableRetroImageView {
    
    /// Generates a UIImage from this view for sharing
    @MainActor
    func generateImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = 1.0
        return renderer.uiImage
    }
}

// MARK: - Preview

#Preview("5 sounds") {
    ScrollView {
        ShareableRetroImageView(
            authorPhoto: nil,
            topSounds: [
                TopChartItem(id: "1", rankNumber: "1", contentId: "s1", contentName: "Drama", contentAuthorId: "a1", contentAuthorName: "Author", shareCount: 20),
                TopChartItem(id: "2", rankNumber: "2", contentId: "s2", contentName: "Tadinha! Que Barra!", contentAuthorId: "a1", contentAuthorName: "Author", shareCount: 15),
                TopChartItem(id: "3", rankNumber: "3", contentId: "s3", contentName: "Trump Bullshit", contentAuthorId: "a1", contentAuthorName: "Author", shareCount: 12),
                TopChartItem(id: "4", rankNumber: "4", contentId: "s4", contentName: "Something", contentAuthorId: "a1", contentAuthorName: "Author", shareCount: 10),
                TopChartItem(id: "5", rankNumber: "5", contentId: "s5", contentName: "Something But Longer So We See It", contentAuthorId: "a1", contentAuthorName: "Author", shareCount: 8)
            ],
            totalShares: 68,
            favoriteDay: "Sexta-feira"
        )
        .scaleEffect(0.4)
        .frame(width: 828 * 0.4, height: 1472 * 0.4)
    }
}

#Preview("3 sounds") {
    ScrollView {
        ShareableRetroImageView(
            authorPhoto: nil,
            topSounds: [
                TopChartItem(id: "1", rankNumber: "1", contentId: "s1", contentName: "Drama", contentAuthorId: "a1", contentAuthorName: "Author", shareCount: 20),
                TopChartItem(id: "2", rankNumber: "2", contentId: "s2", contentName: "Tadinha! Que Barra!", contentAuthorId: "a1", contentAuthorName: "Author", shareCount: 15),
                TopChartItem(id: "3", rankNumber: "3", contentId: "s3", contentName: "Trump Bullshit", contentAuthorId: "a1", contentAuthorName: "Author", shareCount: 12)
            ],
            totalShares: 68,
            favoriteDay: "Segunda-feira"
        )
        .scaleEffect(0.4)
        .frame(width: 828 * 0.4, height: 1472 * 0.4)
    }
}

#Preview("1 sound") {
    ScrollView {
        ShareableRetroImageView(
            authorPhoto: nil,
            topSounds: [
                TopChartItem(id: "1", rankNumber: "1", contentId: "s1", contentName: "Drama", contentAuthorId: "a1", contentAuthorName: "Author", shareCount: 20)
            ],
            totalShares: 68,
            favoriteDay: "Quarta-feira"
        )
        .scaleEffect(0.4)
        .frame(width: 828 * 0.4, height: 1472 * 0.4)
    }
}
