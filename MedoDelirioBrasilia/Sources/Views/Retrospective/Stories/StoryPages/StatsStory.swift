//
//  StatsStory.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/11/25.
//

import SwiftUI

struct StatsStory: View {
    
    let totalShares: Int
    let uniqueSounds: Int
    let favoriteDay: String
    
    @State private var showContent = false
    @State private var animateNumbers = false
    
    private var shareText: String {
        if totalShares == 1 {
            return "1 vez"
        } else {
            return "\(totalShares) vezes"
        }
    }
    
    private var soundText: String {
        if uniqueSounds == 1 {
            return "1 som diferente"
        } else {
            return "\(uniqueSounds) sons diferentes"
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 35) {
                // Title
                Text("Em 2025")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.8), value: showContent)
                
                // Stats grid
                VStack(spacing: 30) {
                    StatRow(
                        icon: "square.and.arrow.up",
                        label: "Você compartilhou",
                        value: shareText,
                        delay: 0.3,
                        show: showContent
                    )
                    
                    StatRow(
                        icon: "waveform",
                        label: "Isso foram",
                        value: soundText,
                        delay: 0.6,
                        show: showContent
                    )
                    
                    if favoriteDay != "-" {
                        StatRow(
                            icon: "calendar",
                            label: "Seu dia favorito",
                            value: favoriteDay,
                            delay: 0.9,
                            show: showContent
                        )
                    }
                }
                .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .onAppear {
            showContent = true
        }
    }
}

// MARK: - Subviews

private struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let delay: Double
    let show: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(.white.opacity(0.9))
            
            Text(label)
                .font(.callout)
                .foregroundStyle(.white.opacity(0.7))
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
        }
        .multilineTextAlignment(.center)
        .opacity(show ? 1.0 : 0.0)
        .offset(y: show ? 0 : 20)
        .animation(.easeOut(duration: 0.8).delay(delay), value: show)
    }
}

#Preview {
    StatsStory(
        totalShares: 127,
        uniqueSounds: 43,
        favoriteDay: "Sexta-feira"
    )
    .background(Color.darkestGreen)
}

