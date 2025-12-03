//
//  TopSoundStory.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/11/25.
//

import SwiftUI

struct TopSoundStory: View {
    
    let rankNumber: Int
    let soundName: String
    let authorName: String
    let shareCount: Int
    
    @State private var showContent = false
    
    private var rankText: String {
        switch rankNumber {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "#\(rankNumber)"
        }
    }
    
    private var shareText: String {
        if shareCount == 1 {
            return "1 compartilhamento"
        } else {
            return "\(shareCount) compartilhamentos"
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 25) {
                // Rank badge
                Text(rankText)
                    .font(.system(size: 80))
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showContent)
                
                // Position text
                Text("Seu #\(rankNumber) som mais compartilhado")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: showContent)
                
                // Sound name
                Text(soundName)
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 30)
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: showContent)
                
                // Author
                Text("por \(authorName)")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.8))
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.6), value: showContent)
                
                Divider()
                    .background(.white.opacity(0.3))
                    .frame(width: 100)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.5).delay(0.8), value: showContent)
                
                // Share count
                Text(shareText)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(1.0), value: showContent)
            }
            .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.horizontal, 30)
        .onAppear {
            showContent = true
        }
    }
}

#Preview {
    TopSoundStory(
        rankNumber: 1,
        soundName: "O Deltan tá chorando",
        authorName: "Pedro Daltro",
        shareCount: 42
    )
    .background(Color.darkerGreen)
}
