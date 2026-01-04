//
//  WelcomeStory.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/11/25.
//

import SwiftUI

struct WelcomeStory: View {
    
    @State private var showText = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("🎧")
                    .font(.system(size: 80))
                    .scaleEffect(showText ? 1.0 : 0.5)
                    .opacity(showText ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showText)
                
                Text("Sua Retrospectiva")
                    .font(.system(size: 42, weight: .bold))
                    .opacity(showText ? 1.0 : 0.0)
                    .offset(y: showText ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: showText)
                
                Text("2025")
                    .font(.system(size: 72, weight: .heavy))
                    .opacity(showText ? 1.0 : 0.0)
                    .offset(y: showText ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: showText)
            }
            .multilineTextAlignment(.center)
            .foregroundStyle(.white)
            
            Spacer()
            
            Text("Toque para continuar")
                .font(.callout)
                .foregroundStyle(.white.opacity(0.7))
                .opacity(showText ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.5).delay(1.0), value: showText)
                .padding(.bottom, 40)
        }
        .onAppear {
            showText = true
        }
    }
}

#Preview {
    WelcomeStory()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.darkestGreen, .green, .yellow]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}

