//
//  IntroducingUniversalSearchView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 17/01/26.
//

import SwiftUI

struct IntroducingUniversalSearchView: View {

    let appMemory: AppPersistentMemoryProtocol

    @Environment(\.dismiss) var dismiss

    @State private var glowAnimation = false
    @State private var pulseAnimation = false
    @State private var ringAnimation = false
    @State private var floatAnimation = false

    private var isIOS26OrLater: Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }

    private var hasHomeIndicator: Bool {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return false
        }
        return window.safeAreaInsets.bottom > 0
    }

    private let gradientColors: [Color] = [
        Color(red: 0.1, green: 0.4, blue: 0.9),
        Color(red: 0.2, green: 0.6, blue: 1.0),
        Color(red: 0.4, green: 0.7, blue: 1.0)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Header with Gradient
                    ZStack {
                        // Gradient background that fades to clear
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .mask(
                            LinearGradient(
                                stops: [
                                    .init(color: .white, location: 0),
                                    .init(color: .white, location: 0.7),
                                    .init(color: .clear, location: 1.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        // Decorative floating circles
                        Circle()
                            .fill(.white.opacity(0.1))
                            .frame(width: 200, height: 200)
                            .offset(
                                x: -100 + (floatAnimation ? 8 : -8),
                                y: -50 + (floatAnimation ? -12 : 12)
                            )
                            .animation(
                                .easeInOut(duration: 4).repeatForever(autoreverses: true),
                                value: floatAnimation
                            )

                        Circle()
                            .fill(.white.opacity(0.08))
                            .frame(width: 150, height: 150)
                            .offset(
                                x: 120 + (floatAnimation ? -10 : 10),
                                y: 30 + (floatAnimation ? 8 : -8)
                            )
                            .animation(
                                .easeInOut(duration: 5).repeatForever(autoreverses: true),
                                value: floatAnimation
                            )

                        Circle()
                            .fill(.white.opacity(0.05))
                            .frame(width: 100, height: 100)
                            .offset(
                                x: 80 + (floatAnimation ? 6 : -6),
                                y: -70 + (floatAnimation ? 10 : -10)
                            )
                            .animation(
                                .easeInOut(duration: 3.5).repeatForever(autoreverses: true),
                                value: floatAnimation
                            )

                        // Content
                        VStack(spacing: 16) {
                            // Search icon with animated glow effect
                            ZStack {
                                // Outer expanding rings
                                ForEach(0..<3, id: \.self) { index in
                                    Circle()
                                        .stroke(.white.opacity(ringAnimation ? 0 : 0.3), lineWidth: 2)
                                        .frame(width: 70, height: 70)
                                        .scaleEffect(ringAnimation ? 2.2 : 1)
                                        .animation(
                                            .easeOut(duration: 2.5)
                                            .repeatForever(autoreverses: false)
                                            .delay(Double(index) * 0.8),
                                            value: ringAnimation
                                        )
                                }

                                // Pulsing outer glow
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                .white.opacity(pulseAnimation ? 0.4 : 0.2),
                                                .white.opacity(0)
                                            ],
                                            center: .center,
                                            startRadius: 30,
                                            endRadius: pulseAnimation ? 70 : 55
                                        )
                                    )
                                    .frame(width: 140, height: 140)
                                    .animation(
                                        .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                                        value: pulseAnimation
                                    )

                                // Inner soft glow
                                Circle()
                                    .fill(.white.opacity(glowAnimation ? 0.35 : 0.25))
                                    .frame(width: 80, height: 80)
                                    .blur(radius: 15)
                                    .animation(
                                        .easeInOut(duration: 2).repeatForever(autoreverses: true),
                                        value: glowAnimation
                                    )

                                // Solid backdrop circle
                                Circle()
                                    .fill(.white.opacity(0.25))
                                    .frame(width: 70, height: 70)

                                // The icon with subtle scale animation
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(.white)
                                    .shadow(color: .white.opacity(0.8), radius: glowAnimation ? 12 : 6)
                                    .scaleEffect(glowAnimation ? 1.05 : 1.0)
                                    .animation(
                                        .easeInOut(duration: 2).repeatForever(autoreverses: true),
                                        value: glowAnimation
                                    )
                            }
                            .onAppear {
                                glowAnimation = true
                                pulseAnimation = true
                                ringAnimation = true
                                floatAnimation = true
                            }

                            VStack(spacing: .spacing(.nano)) {
                                Text("Busca")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)

                                Text("Universal")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.9))
                            }

                            Text("Uma nova forma de encontrar tudo")
                                .font(.subheadline)
                                .foregroundStyle(.primary.opacity(0.85))
                        }
                        .padding(.vertical, 40)
                    }
                    .frame(height: 300)

                    // Features Section
                    VStack(alignment: .leading, spacing: 24) {
                        ItemView(
                            icon: "sparkle.magnifyingglass",
                            iconColor: Color(red: 0.2, green: 0.5, blue: 1.0),
                            title: "Tudo Em Um Só Lugar",
                            message: "Encontre vírgulas, músicas, autores, pastas e reações com uma única busca."
                        )

                        ItemView(
                            icon: "clock.arrow.circlepath",
                            iconColor: Color(red: 0.4, green: 0.65, blue: 1.0),
                            title: "Pesquisas Recentes",
                            message: "Acesse rapidamente suas buscas anteriores para encontrar aquela vírgula que você já conhece."
                        )

                        if isIOS26OrLater {
                            ItemView(
                                icon: "hand.tap.fill",
                                iconColor: Color(red: 0.15, green: 0.45, blue: 0.95),
                                title: "Acesso Facilitado",
                                message: "No iOS 26, a busca agora tem um botão dedicado no canto inferior direito."
                            )
                        } else {
                            ItemView(
                                icon: "checkmark.circle",
                                iconColor: Color(red: 0.15, green: 0.45, blue: 0.95),
                                title: "No Mesmo Lugar de Sempre",
                                message: "A busca continua no topo da tela, no mesmo lugar que você já conhece."
                            )
                        }
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 24)
                }
            }
            .ignoresSafeArea(edges: .top)
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .center) {
                    dismissButton

                    Spacer()
                        .frame(height: hasHomeIndicator ? 40 : 16)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.systemBackground)
            }
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
    }

    @ViewBuilder
    private var dismissButton: some View {
        if #available(iOS 26.0, *) {
            Button {
                appMemory.hasSeenUniversalSearchWhatsNewScreen(true)
                dismiss()
            } label: {
                Text("Bora buscar!")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.glassProminent)
            .tint(Color(red: 0.2, green: 0.5, blue: 1.0))
        } else {
            Button {
                appMemory.hasSeenUniversalSearchWhatsNewScreen(true)
                dismiss()
            } label: {
                HStack {
                    Spacer()
                    Text("Bora buscar!")
                        .font(.headline)
                        .bold()
                    Spacer()
                }
            }
            .largeRoundedRectangleBorderedProminent(colored: Color(red: 0.2, green: 0.5, blue: 1.0))
        }
    }
}

// MARK: - Subviews

extension IntroducingUniversalSearchView {

    struct ItemView: View {

        let icon: String
        let iconColor: Color
        let title: String
        let message: String

        var body: some View {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundStyle(iconColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("As Standalone View") {
    IntroducingUniversalSearchView(appMemory: AppPersistentMemory.shared)
}

#Preview("As Sheet") {
    VStack {
        Text("Stuff")
        Text("Stuff")
        Text("Stuff")
    }
    .sheet(isPresented: .constant(true)) {
        IntroducingUniversalSearchView(appMemory: AppPersistentMemory.shared)
    }
}
