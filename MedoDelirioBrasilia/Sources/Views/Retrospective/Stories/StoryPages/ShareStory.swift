//
//  ShareStory.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/11/25.
//

import SwiftUI

struct ShareStory: View {
    
    let topAuthor: TopAuthorItem?
    let topSounds: [TopChartItem]
    let totalShares: Int
    let favoriteDay: String
    
    @State private var showContent = false
    @State private var shareableImage: Image?
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 30) {
                // Icon
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.white)
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showContent)
                
                // Message
                VStack(spacing: 15) {
                    Text("Gostou?")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("Compartilhe sua retrospectiva\nnas redes sociais!")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .multilineTextAlignment(.center)
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.8).delay(0.3), value: showContent)
                
                // Share button using ShareLink
                if let image = shareableImage {
                    ShareLink(
                        item: image,
                        preview: SharePreview("Minha Retrospectiva 2025", image: image)
                    ) {
                        Text("Compartilhar")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.darkestGreen)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background {
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(.white)
                            }
                    }
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.6), value: showContent)
                    .padding(.top, 10)
                } else {
                    // Placeholder while image generates
                    ProgressView()
                        .tint(.white)
                        .padding(.top, 10)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .onAppear {
            showContent = true
            generateShareableImage()
            if let author = topAuthor {
                print("Top Author: \(author.authorName), Photo: \(author.authorPhoto ?? "none"), Shares: \(author.shareCount)")
            }
        }
    }
    
    // MARK: - Image Generation
    
    private func generateShareableImage() {
        let shareCard = ShareableRetroImageView(
            authorPhotoURL: topAuthor?.authorPhoto,
            topSounds: topSounds,
            totalShares: totalShares,
            favoriteDay: favoriteDay
        )
        
        if let uiImage = shareCard.generateImage() {
            shareableImage = Image(uiImage: uiImage)
        }
    }
}

#Preview {
    ShareStory(
        topAuthor: nil,
        topSounds: [],
        totalShares: 68,
        favoriteDay: "Sexta-feira"
    )
    .background(
        LinearGradient(
            gradient: Gradient(colors: [.yellow, .green, .darkestGreen]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
