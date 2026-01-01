//
//  Retro2025Banner.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/10/24.
//

import SwiftUI

public enum RetroBannerStyle {

    case full
    case small
}

struct Retro2025Banner: View {

    var style: RetroBannerStyle = .full
    let openStoriesAction: () -> Void
    let dismissAction: () -> Void

    var body: some View {
        switch style {
        case .full:
            VStack(alignment: .center, spacing: .spacing(.large)) {
                Text("Retrospectiva 2025")
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)

                Text("Bora ver o que nós aprontamos juntos esse ano?")
                    .font(.callout)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.2), radius: 1, y: 1)

                Button {
                    openStoriesAction()
                } label: {
                    Text("Bora!")
                        .font(.callout)
                        .foregroundStyle(.black)
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white)
                        }
                }
                .padding(.top, 5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, .spacing(.xxxLarge))
            .padding(.horizontal, 24)
            .background {
                FlowingGradientBackground()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    dismissAction()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                }
                .padding()
            }
        case .small:
            HStack(spacing: .spacing(.large)) {
                VStack(alignment: .leading, spacing: .spacing(.small)) {
                    Text("Retrospectiva 2025")
                        .font(.title2)
                        .foregroundColor(.white)
                        .bold()
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)

                    Text("Bora ver o que nós aprontamos juntos esse ano?")
                        .font(.callout)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                }

                Button {
                    openStoriesAction()
                } label: {
                    Text("Bora!")
                        .font(.callout)
                        .foregroundStyle(.black)
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white)
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, .spacing(.xLarge))
            .padding(.horizontal, .spacing(.xLarge))
            .background {
                FlowingGradientBackground()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    dismissAction()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                }
                .padding(.spacing(.small))
            }
        }
    }
}

// MARK: - Flowing Gradient Background

struct FlowingGradientBackground: View {
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/30)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            
            Canvas { context, size in
                // Draw liquid-like flowing gradient
                drawLiquidGradient(context: context, size: size, time: time)
            }
            .overlay {
                // Very subtle film grain - light only
                FilmGrainView(time: time)
                    .blendMode(.plusLighter)
                    .opacity(0.02)
            }
        }
    }
    
    private func drawLiquidGradient(context: GraphicsContext, size: CGSize, time: Double) {
        // Multiple wave frequencies for organic liquid motion
        let t = time * 0.5
        
        // Liquid blob movements - sideways and vertical
        let blobX = sin(t * 1.2) * 0.4 + cos(t * 0.7) * 0.3
        let blobY = cos(t * 0.9) * 0.5 + sin(t * 1.4) * 0.2
        let blobX2 = cos(t * 0.8 + 2.0) * 0.35 + sin(t * 1.1) * 0.25
        let blobY2 = sin(t * 1.0 + 1.0) * 0.4 + cos(t * 0.6) * 0.3
        
        // Swirl effect - gradient rotates around center
        let swirl = t * 0.3
        let centerX = 0.5 + sin(swirl) * 0.3
        let centerY = 0.5 + cos(swirl) * 0.3
        
        // Colors that shift and breathe
        let hueShift = sin(t * 0.4) * 0.05
        let colors: [Color] = [
            Color(hue: 0.42 + hueShift, saturation: 0.85, brightness: 0.35),  // Deep green
            Color(hue: 0.35 + hueShift, saturation: 0.80, brightness: 0.50),  // Forest
            Color(hue: 0.28 + hueShift, saturation: 0.75, brightness: 0.60),  // Lime
            Color(hue: 0.14 + hueShift, saturation: 0.85, brightness: 0.75),  // Gold
        ]
        
        // Primary gradient - flows diagonally with liquid motion
        let startPoint = CGPoint(
            x: size.width * (centerX + blobX),
            y: size.height * (centerY + blobY)
        )
        let endPoint = CGPoint(
            x: size.width * (1.0 - centerX + blobX2),
            y: size.height * (1.0 - centerY + blobY2)
        )
        
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(
                Gradient(colors: colors),
                startPoint: startPoint,
                endPoint: endPoint
            )
        )
        
        // Second layer - horizontal wave
        let wavePhase = t * 0.6
        let wave2Start = CGPoint(
            x: size.width * (0.0 + sin(wavePhase) * 0.5),
            y: size.height * (0.5 + cos(wavePhase * 1.3) * 0.4)
        )
        let wave2End = CGPoint(
            x: size.width * (1.0 + cos(wavePhase) * 0.5),
            y: size.height * (0.5 + sin(wavePhase * 0.8) * 0.4)
        )
        
        let overlayColors: [Color] = [
            Color.clear,
            Color(hue: 0.50, saturation: 0.6, brightness: 0.45).opacity(0.25),
            Color(hue: 0.18, saturation: 0.7, brightness: 0.65).opacity(0.20),
            Color.clear
        ]
        
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(
                Gradient(colors: overlayColors),
                startPoint: wave2Start,
                endPoint: wave2End
            )
        )
        
        // Third layer - vertical breathing
        let breathe = sin(t * 0.8) * 0.3
        let vertStart = CGPoint(
            x: size.width * (0.5 + cos(t * 0.5) * 0.4),
            y: size.height * (0.0 + breathe)
        )
        let vertEnd = CGPoint(
            x: size.width * (0.5 + sin(t * 0.7) * 0.4),
            y: size.height * (1.0 - breathe)
        )
        
        let breatheColors: [Color] = [
            Color(hue: 0.12, saturation: 0.8, brightness: 0.7).opacity(0.15),
            Color.clear,
            Color(hue: 0.45, saturation: 0.7, brightness: 0.4).opacity(0.12),
        ]
        
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(
                Gradient(colors: breatheColors),
                startPoint: vertStart,
                endPoint: vertEnd
            )
        )
    }
}

// MARK: - Film Grain View

struct FilmGrainView: View {
    let time: Double
    
    var body: some View {
        Canvas { context, size in
            // Use time to create animated noise
            let seed = Int(time * 8) % 1000
            var rng = SeededRandomGenerator(seed: seed)
            
            // Sparse, light grain pixels
            let pixelSize: CGFloat = 2
            let columns = Int(size.width / pixelSize) + 1
            let rows = Int(size.height / pixelSize) + 1
            
            for row in 0..<rows {
                for col in 0..<columns {
                    let noise = CGFloat.random(in: 0...1, using: &rng)
                    // Only draw ~30% of pixels, and keep them very light
                    guard noise > 0.7 else { continue }
                    let opacity = (noise - 0.7) * 0.4 // Very subtle: 0 to 0.12 range
                    
                    let rect = CGRect(
                        x: CGFloat(col) * pixelSize,
                        y: CGFloat(row) * pixelSize,
                        width: pixelSize,
                        height: pixelSize
                    )
                    
                    context.fill(
                        Path(rect),
                        with: .color(Color.white.opacity(opacity))
                    )
                }
            }
        }
    }
}

// MARK: - Seeded Random Generator

struct SeededRandomGenerator: RandomNumberGenerator {
    var state: UInt64
    
    init(seed: Int) {
        state = UInt64(abs(seed) + 1)
    }
    
    mutating func next() -> UInt64 {
        // Simple LCG random number generator
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

// MARK: - Preview

#Preview("Full") {
    Retro2025Banner(
        openStoriesAction: {},
        dismissAction: {}
    )
    .padding()
}

#Preview("Small") {
    Retro2025Banner(
        style: RetroBannerStyle.small,
        openStoriesAction: {},
        dismissAction: {}
    )
    .padding()
}
