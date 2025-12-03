//
//  SurpriseIntroView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/12/25.
//

import SwiftUI

struct SurpriseIntroView: View {
    
    let onComplete: () -> Void
    
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0.0
    @State private var textOffset: CGFloat = 50
    @State private var backgroundOpacity: Double = 0.0
    @State private var skullScale: CGFloat = 1.0
    @State private var skullShake: CGFloat = 0
    
    // Background emoji configurations for organic scattered look
    private let scatteredEmojis: [(emoji: String, x: CGFloat, y: CGFloat, size: CGFloat, rotation: Double, opacity: Double)] = [
        // Locks 🔒
        ("🔒", 0.15, 0.12, 32, -15, 0.15),
        ("🔒", 0.82, 0.18, 28, 20, 0.12),
        ("🔒", 0.08, 0.45, 24, -8, 0.18),
        ("🔒", 0.88, 0.52, 30, 12, 0.14),
        ("🔒", 0.25, 0.78, 26, -22, 0.16),
        ("🔒", 0.72, 0.85, 22, 18, 0.13),
        
        // Police cars 🚓
        ("🚓", 0.78, 0.08, 30, 25, 0.14),
        ("🚓", 0.22, 0.22, 26, -18, 0.16),
        ("🚓", 0.92, 0.38, 24, 8, 0.12),
        ("🚓", 0.05, 0.62, 28, -25, 0.15),
        ("🚓", 0.68, 0.72, 32, 15, 0.18),
        ("🚓", 0.35, 0.88, 24, -12, 0.13),
        
        // Trumpets 🎺
        ("🎺", 0.12, 0.28, 28, 30, 0.16),
        ("🎺", 0.85, 0.32, 26, -20, 0.14),
        ("🎺", 0.18, 0.58, 30, 15, 0.12),
        ("🎺", 0.75, 0.62, 24, -28, 0.17),
        ("🎺", 0.42, 0.15, 22, 22, 0.13),
        ("🎺", 0.58, 0.82, 28, -10, 0.15),
        
        // Judges 🧑‍⚖️
        ("🧑‍⚖️", 0.10, 0.35, 26, -12, 0.14),
        ("🧑‍⚖️", 0.90, 0.25, 28, 16, 0.16),
        ("🧑‍⚖️", 0.28, 0.68, 24, 8, 0.13),
        ("🧑‍⚖️", 0.65, 0.42, 30, -20, 0.15),
        ("🧑‍⚖️", 0.48, 0.92, 26, 25, 0.17),
        ("🧑‍⚖️", 0.82, 0.75, 22, -8, 0.12),
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark background
                Color.black
                    .ignoresSafeArea()
                
                // Scattered background emojis
                ForEach(0..<scatteredEmojis.count, id: \.self) { index in
                    let config = scatteredEmojis[index]
                    Text(config.emoji)
                        .font(.system(size: config.size))
                        .rotationEffect(.degrees(config.rotation))
                        .opacity(config.opacity * backgroundOpacity)
                        .position(
                            x: geometry.size.width * config.x,
                            y: geometry.size.height * config.y
                        )
                }
                
                // Main content
                VStack(spacing: 20) {
                    // Large centered skull with spooky effect
                    Text("💀")
                        .font(.system(size: 120))
                        .scaleEffect(skullScale)
                        .rotationEffect(.degrees(skullShake))
                        .shadow(color: .white.opacity(0.3), radius: 20)
                    
                    // Question text
                    Text("Você está lendo isso mas sabe quem não está?")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Main punchline
                    Text("JAIL BOLSONARO.")
                        .font(.system(size: 36, weight: .black))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                .offset(y: textOffset)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Phase 1: Fade in background emojis slightly before main content
        withAnimation(.easeOut(duration: 0.5)) {
            backgroundOpacity = 1.0
        }
        
        // Phase 1b: Zoom in and fade in main content (0.8s)
        withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
            scale = 1.0
            opacity = 1.0
            textOffset = 0
        }
        
        // Phase 2: Skull grows larger and shakes (spooky effect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Grow the skull
            withAnimation(.easeInOut(duration: 0.3)) {
                skullScale = 1.4
            }
            
            // Shake sequence
            shakeSkull()
        }
        
        // Phase 2b: Skull returns to normal size
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeOut(duration: 0.2)) {
                skullScale = 1.0
                skullShake = 0
            }
        }
        
        // Phase 3: Hold for a moment, then fade out (after 2.8s total)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeIn(duration: 0.6)) {
                opacity = 0.0
                scale = 1.1
                backgroundOpacity = 0.0
            }
        }
        
        // Phase 4: Complete and transition (after 3.5s total)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            onComplete()
        }
    }
    
    private func shakeSkull() {
        let shakeDuration = 0.08
        let shakeAngles: [CGFloat] = [-8, 8, -6, 6, -4, 4, -2, 2, 0]
        
        for (index, angle) in shakeAngles.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + shakeDuration * Double(index)) {
                withAnimation(.linear(duration: shakeDuration)) {
                    skullShake = angle
                }
            }
        }
    }
}

#Preview {
    SurpriseIntroView(onComplete: {})
}
