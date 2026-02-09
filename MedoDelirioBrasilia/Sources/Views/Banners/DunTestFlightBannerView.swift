//
//  DunTestFlightBannerView.swift
//  MedoDelirioBrasilia
//

import SwiftUI

private let dunTestFlightURL = "https://testflight.apple.com/join/sXFjACxY"

struct DunTestFlightBannerView: View {

    @Binding var isBeingShown: Bool
    var onVerTestFlightTapped: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing(.medium)) {
            Text("🏰  Testando: Dùn")
                .foregroundColor(.purple)
                .font(.headline)
                .bold()

            VStack(alignment: .leading, spacing: .spacing(.xSmall)) {
                Text("Links privados, separados do Safari.")
                    //.foregroundColor(.purple)
                    .opacity(colorScheme == .dark ? 0.9 : 0.85)
                    .font(.callout)
                
                Text("Face ID, local, sem nuvem.")
                    //.foregroundColor(.purple)
                    .opacity(colorScheme == .dark ? 0.9 : 0.85)
                    .font(.callout)
                
                Text("Quer ajudar testando?")
                    //.foregroundColor(.purple)
                    .opacity(colorScheme == .dark ? 0.9 : 0.85)
                    .font(.callout)
            }

            HStack(spacing: 12) {
                Button {
                    onVerTestFlightTapped()
                } label: {
                    Text("Ver TestFlight")
                        .bold()
                        .padding(.horizontal, .spacing(.small))
                        .padding(.vertical, .spacing(.xxxSmall))
                }
                .tint(.purple)
                .controlSize(.regular)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)

                Spacer()
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.4), Color.purple.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(colorScheme == .dark ? 1.5 : 0.15)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        }
        .shadow(color: .purple.opacity(0.15), radius: 8, x: 0, y: 4)
        .overlay(alignment: .topTrailing) {
            Button {
                AppPersistentMemory.shared.setHasSeenDunTestFlightBanner(to: true)
                isBeingShown = false
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.purple)
            }
            .padding()
            .accessibilityLabel("Fechar")
        }
    }
}

// MARK: - Expanded view (sheet content)

struct DunTestFlightExpandedView: View {

    var onSimQueroTestar: () -> Void
    var onTalvezDepois: () -> Void

    @Environment(\.colorScheme) var colorScheme

    private var expandedBodyColor: Color {
        colorScheme == .dark ? Color(white: 0.88) : .secondary
    }

    private var dunGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(hex: "7C3AED"), location: 0),
                .init(color: Color(hex: "4338CA"), location: 0.15),
                .init(color: Color(hex: "6366F1"), location: 0.3),
                .init(color: Color.systemBackground, location: 0.5),
                .init(color: Color.systemBackground, location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        ZStack(alignment: .top) {
            dunGradient
                .frame(maxWidth: .infinity)
                .frame(height: 320)
                .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Image("DunAppIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                        .padding()

                    Text("Dùn - Links Privados")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)

                Text("Já teve links pessoais aparecendo nas sugestões do Safari na hora errada?")
                    .font(.body)
                    .foregroundColor(expandedBodyColor)

                Text("Dùn é um espaço separado, protegido por Face ID, pra guardar links que você não quer misturados com o trabalho.")
                    .font(.body)
                    .foregroundColor(expandedBodyColor)

                VStack(alignment: .leading, spacing: 8) {
                    bulletRow("Armazenamento local")
                    bulletRow("Tags simples")
                    bulletRow("Busca rápida")
                    bulletRow("Sem nuvem (por enquanto)")
                }

                Text("Tá em TestFlight. Preciso de ~20 testadores pra dar feedback antes do lançamento.")
                    .font(.body)
                    .foregroundColor(expandedBodyColor)

                Text("Bora ajudar?")
                    .font(.headline)
                    .foregroundColor(.primary)

                VStack(spacing: 12) {
                    Button {
                        OpenUtility.open(link: dunTestFlightURL)
                        onSimQueroTestar()
                    } label: {
                        Text("Sim, Quero Testar")
                            .padding(.vertical, .spacing(.xSmall))
                            .frame(maxWidth: .infinity)
                    }
                    .accessibilityLabel("Abrir TestFlight para testar Dùn")
                    .simQueroTestarButtonStyle()

                    Button {
                        onTalvezDepois()
                    } label: {
                        Text("Talvez Depois")
                            .padding(.vertical, .spacing(.xSmall))
                            .frame(maxWidth: .infinity)
                    }
                    .accessibilityLabel("Fechar e talvez testar depois")
                    .talvezDepoisButtonStyle()
                }
                .padding(.top, 8)
            }
            .padding(24)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private func bulletRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.purple)
            Text(text)
                .font(.body)
                .foregroundColor(expandedBodyColor)
        }
    }
}

// MARK: - Glass button style helpers (iOS 26+ glass, fallback for older)

private extension View {

    @ViewBuilder
    func simQueroTestarButtonStyle() -> some View {
        if #available(iOS 26, *) {
            self
                .buttonStyle(.glassProminent)
                .tint(.purple)
        } else {
            self
                .tint(.purple)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle)
        }
    }

    @ViewBuilder
    func talvezDepoisButtonStyle() -> some View {
        if #available(iOS 26, *) {
            self
                .buttonStyle(.glass)
                .tint(.purple)
        } else {
            self
                .tint(.purple)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
        }
    }
}

// MARK: - Previews

#Preview("Compact banner") {
    DunTestFlightBannerView(
        isBeingShown: .constant(true),
        onVerTestFlightTapped: {}
    )
    .padding()
}

#Preview("Expanded view") {
    DunTestFlightExpandedView(
        onSimQueroTestar: {},
        onTalvezDepois: {}
    )
}
