//
//  SummaryCardView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/11/25.
//

import SwiftUI

/// A shareable summary card showing the user's 2025 retrospective stats
struct SummaryCardView: View {
    
    let totalShares: Int
    let uniqueSounds: Int
    let topSound: TopChartItem?
    
    private var shareText: String {
        totalShares == 1 ? "1 compartilhamento" : "\(totalShares) compartilhamentos"
    }
    
    private var soundText: String {
        uniqueSounds == 1 ? "1 som" : "\(uniqueSounds) sons"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Text("🎧")
                    .font(.system(size: 60))
                
                Text("Minha Retrospectiva")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("2025")
                    .font(.system(size: 48, weight: .heavy))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 50)
            .padding(.bottom, 40)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.darkestGreen, .green]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            // Stats content
            VStack(spacing: 30) {
                StatBlock(
                    icon: "square.and.arrow.up.fill",
                    value: shareText,
                    label: "no ano"
                )
                
                StatBlock(
                    icon: "waveform",
                    value: soundText,
                    label: "diferentes"
                )
                
                if let topSound = topSound {
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(.yellow)
                            Text("Meu som favorito")
                                .font(.headline)
                                .foregroundStyle(.green)
                        }
                        
                        Text(topSound.contentName)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.darkestGreen)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("por \(topSound.contentAuthorName)")
                            .font(.callout)
                            .foregroundStyle(Color.darkerGreen)
                    }
                    .padding(.top, 10)
                }
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity)
            .background(.white)
            
            // Footer
            HStack(spacing: 8) {
                Text("Medo e Delírio")
                    .font(.callout)
                    .fontWeight(.semibold)
                
                Text("•")
                
                Text("App")
                    .font(.callout)
            }
            .foregroundStyle(.white.opacity(0.9))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.darkestGreen)
        }
        .frame(width: 400, height: 600)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
    }
}

// MARK: - Subviews

private struct StatBlock: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(.green)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.darkestGreen)
            
            Text(label)
                .font(.callout)
                .foregroundStyle(Color.darkerGreen)
        }
    }
}

// MARK: - Image Generation

extension SummaryCardView {
    
    /// Generates a UIImage from the summary card view
    @MainActor
    func generateImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = 3.0 // High resolution for sharing
        return renderer.uiImage
    }
}

#Preview {
    SummaryCardView(
        totalShares: 127,
        uniqueSounds: 43,
        topSound: TopChartItem(
            id: "1",
            rankNumber: "1",
            contentId: "123",
            contentName: "O Deltan tá chorando",
            contentAuthorId: "author-1",
            contentAuthorName: "Pedro Daltro",
            shareCount: 42
        )
    )
    .padding()
    .background(.gray.opacity(0.3))
}

