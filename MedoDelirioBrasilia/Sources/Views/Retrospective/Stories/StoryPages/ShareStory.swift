//
//  ShareStory.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/11/25.
//

import SwiftUI
import Kingfisher

struct ShareStory: View {
    
    let topAuthor: TopAuthorItem?
    let topSounds: [TopChartItem]
    let totalShares: Int
    let favoriteDay: String
    
    @State private var showContent = false
    @State private var shareableImage: Image?
    @State private var isLoadingImage = true
    
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
            if let author = topAuthor {
                print("Top Author: \(author.authorName), Photo: \(author.authorPhoto ?? "none"), Shares: \(author.shareCount)")
            }
            print("Top Sounds count: \(topSounds.count)")
            for (index, sound) in topSounds.enumerated() {
                print("  \(index + 1). \(sound.contentName)")
            }
        }
        .task {
            await generateShareableImage()
        }
    }
    
    // MARK: - Image Generation
    
    private func generateShareableImage() async {
        // First, download the author photo if available
        var authorImage: UIImage? = nil
        
        if let photoURLString = topAuthor?.authorPhoto,
           let photoURL = URL(string: photoURLString) {
            authorImage = await downloadImage(from: photoURL)
        }
        
        // Generate the shareable image with the pre-downloaded photo
        let shareCard = ShareableRetroImageView(
            authorPhoto: authorImage,
            topSounds: topSounds,
            totalShares: totalShares,
            favoriteDay: favoriteDay
        )
        
        if let uiImage = shareCard.generateImage() {
            shareableImage = Image(uiImage: uiImage)
        }
        
        isLoadingImage = false
    }
    
    private func downloadImage(from url: URL) async -> UIImage? {
        await withCheckedContinuation { continuation in
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let imageResult):
                    continuation.resume(returning: imageResult.image)
                case .failure(let error):
                    print("Failed to download author photo: \(error)")
                    continuation.resume(returning: nil)
                }
            }
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
