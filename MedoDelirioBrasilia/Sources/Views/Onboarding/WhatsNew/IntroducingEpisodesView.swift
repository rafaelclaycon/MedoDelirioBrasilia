//
//  IntroducingEpisodesView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import SwiftUI

struct IntroducingEpisodesView: View {

    let appMemory: AppPersistentMemoryProtocol

    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    private var hasHomeIndicator: Bool {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return false
        }
        return window.safeAreaInsets.bottom > 0
    }

    private var gradientColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.02, green: 0.12, blue: 0.05),
                Color(red: 0.05, green: 0.20, blue: 0.08),
                Color(red: 0.10, green: 0.30, blue: 0.12)
            ]
        } else {
            return [
                Color(red: 0.15, green: 0.65, blue: 0.30),
                Color(red: 0.25, green: 0.75, blue: 0.40),
                Color(red: 0.40, green: 0.85, blue: 0.50)
            ]
        }
    }

    private let accentGreen = Color(red: 0.20, green: 0.70, blue: 0.35)

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ZStack {
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

                        EpisodeTapestryView(colorScheme: colorScheme)

                        VStack(spacing: 8) {
                            Spacer()

                            Text("NOVIDADE DA VERSÃO 11")
                                .font(.footnote)
                                .bold()
                                .foregroundStyle(
                                    colorScheme == .dark
                                        ? Color.primary.opacity(0.85)
                                        : Color(red: 0.0, green: 0.25, blue: 0.1)
                                )

                            Text("Episódios no App!")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.6), radius: 12, x: 0, y: 2)

                            Text("Spotify? Nunca ouvi falar.")
                                .font(.headline)
                                .foregroundStyle(
                                    colorScheme == .dark
                                        ? Color.primary.opacity(0.85)
                                        : Color(red: 0.0, green: 0.25, blue: 0.1)
                                )

                            Spacer()
                                .frame(height: 16)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                    }
                    .frame(height: 300)
                    .clipped()

                    VStack(alignment: .leading, spacing: 24) {
                        featureItem(
                            icon: "headphones",
                            title: "Ouça Direto no App",
                            message: "Todos os episódios disponíveis para ouvir. Baixe e escute offline, sem precisar sair do app."
                        )

                        featureItem(
                            icon: "bookmark.fill",
                            title: "Marque Seus Momentos",
                            message: "Salve marcadores nos pontos mais importantes para revisitar depois."
                        )

                        featureItem(
                            icon: "line.3.horizontal.decrease.circle",
                            title: "Organize do Seu Jeito",
                            message: "Filtre por favoritos, finalizados e não reproduzidos. Ordene por data para encontrar o que importa."
                        )
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
                appMemory.hasSeenEpisodesWhatsNewScreen(true)
                dismiss()
            } label: {
                Text("Cristiano, seu lix*!")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.glassProminent)
            .tint(.green)
        } else {
            Button {
                appMemory.hasSeenEpisodesWhatsNewScreen(true)
                dismiss()
            } label: {
                HStack {
                    Spacer()
                    Text("Bora ouvir!")
                        .font(.headline)
                        .bold()
                    Spacer()
                }
            }
            .largeRoundedRectangleBorderedProminent(colored: accentGreen)
        }
    }

    private func featureItem(icon: String, title: String, message: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(accentGreen)
                .frame(width: 36)

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

// MARK: - Subviews

extension IntroducingEpisodesView {

    struct EpisodeTapestryView: View {

        let colorScheme: ColorScheme

        private static let episodes: [(title: String, date: String, desc: String, duration: String)] = [
            ("Medo, Delírio e Músicas 9", "18 FEV 2026", "A nona edição musical do podcast com os melhores hits", "1:05:45"),
            ("6x1 e seus cínicos", "12 FEV 2026", "O debate sobre a jornada de trabalho e quem se opõe", "58:30"),
            ("Diário de um detento", "11 FEV 2026", "Os bastidores da prisão mais comentada do momento", "1:12:00"),
            ("Reabertura dos trabalhos", "07 FEV 2026", "Brasília volta do recesso e já começa com polêmica", "47:15"),
            ("Nikolas no Pânico", "05 FEV 2026", "A entrevista que deu o que falar nas redes sociais", "1:01:20"),
            ("Gaza", "30 JAN 2026", "Análise completa do conflito e suas repercussões globais", "1:22:10"),
            ("A derrocada dos Bolsonaros", "23 JAN 2026", "O futuro político da família mais polêmica do Brasil", "55:40"),
            ("A distopia trumpiana", "22 JAN 2026", "Os primeiros dias do novo governo americano", "1:08:55"),
            ("Banco Master, enfim", "16 JAN 2026", "A saga financeira que abalou o mercado brasileiro", "42:30"),
            ("Sobre dezembro", "15 JAN 2026", "Retrospectiva do mês mais turbulento do ano", "1:15:00"),
            ("Muito medo & muito delírio", "10 JAN 2026", "América Latina em ebulição política e social", "59:45"),
            ("Medo, Delírio e RFK", "19 DEZ 2025", "Robert F. Kennedy Jr. e a nova política americana", "1:03:20"),
            ("Medo, Delírio e Músicas 8", "12 DEZ 2025", "A oitava edição com as trilhas sonoras da política", "1:10:00"),
            ("Um ácido estragado", "04 DEZ 2025", "Quando as estratégias políticas saem pela culatra", "48:55"),
            ("São Paulo não tem isso", "02 DEZ 2025", "As peculiaridades da política paulistana em debate", "52:10"),
            ("Jair e o ferro de solda", "27 NOV 2025", "Os últimos capítulos de uma era política conturbada", "1:18:30"),
            ("Tarcísio e um coach", "21 NOV 2025", "A ascensão política e os bastidores do poder", "56:20"),
            ("Miedo y Delirio", "20 NOV 2025", "Edição especial em espanhol sobre a América Latina", "1:05:00"),
            ("A direita se fodendo", "23 OUT 2025", "Os tropeços da oposição no cenário nacional", "44:30"),
            ("Vai, Cármen Lúcia!", "17 OUT 2025", "O STF em foco e as decisões que mudaram o jogo", "1:00:15"),
            ("O voto do cabeça de peruca", "16 OUT 2025", "Análise do voto mais comentado do Supremo", "38:45"),
            ("Medo e Delírio na ONU", "08 OUT 2025", "O Brasil no palco internacional e suas contradições", "1:11:00"),
            ("O voto do careca", "20 SET 2025", "Mais um capítulo do julgamento que dividiu o país", "45:30"),
            ("Briguem, desgraçados!", "30 AGO 2025", "O racha interno dos partidos e o que vem por aí", "57:00"),
            ("A pancadaria em Brasília", "04 JUL 2025", "O dia em que o Congresso virou ringue", "1:02:45"),
        ]

        private let rowCount = 7
        private let brickSpacing: CGFloat = 8
        private let rowSpacing: CGFloat = 8
        private let brickWidth: CGFloat = 220

        var body: some View {
            GeometryReader { _ in
                TimelineView(.animation) { timeline in
                    let elapsed = timeline.date.timeIntervalSinceReferenceDate

                    VStack(spacing: rowSpacing) {
                        ForEach(0..<rowCount, id: \.self) { rowIndex in
                            brickRow(index: rowIndex, elapsed: elapsed)
                        }
                    }
                }
            }
            .clipped()
            .allowsHitTesting(false)
        }

        private func brickRow(index: Int, elapsed: TimeInterval) -> some View {
            let speed = 18.0 + Double(index % 3) * 6.0
            let stripWidth = Double(brickWidth + brickSpacing) * 6
            let cycleDuration = stripWidth / speed
            let progress = elapsed.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration

            let slideOffset: CGFloat = -progress * stripWidth
            let brickOffset: CGFloat = index.isMultiple(of: 2) ? 0 : -(brickWidth * 0.5)

            let startAt = (index * 3) % Self.episodes.count
            let episodesInRow = (0..<6).map {
                Self.episodes[($0 + startAt) % Self.episodes.count]
            }

            let opacity = 0.15 + Double(index % 3) * 0.08

            return HStack(spacing: brickSpacing) {
                ForEach(0..<episodesInRow.count * 2, id: \.self) { i in
                    let ep = episodesInRow[i % episodesInRow.count]
                    brickCell(
                        title: ep.title,
                        date: ep.date,
                        desc: ep.desc,
                        duration: ep.duration,
                        opacity: opacity
                    )
                }
            }
            .offset(x: slideOffset + brickOffset)
        }

        private func brickCell(
            title: String,
            date: String,
            desc: String,
            duration: String,
            opacity: Double
        ) -> some View {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(date)
                        .font(.system(size: 8, weight: .medium))
                        .tracking(0.5)

                    Text(title)
                        .font(.system(size: 11, weight: .semibold, design: .serif))
                        .lineLimit(1)

                    Text(desc)
                        .font(.system(size: 9))
                        .lineLimit(1)
                        .opacity(0.7)
                }

                Spacer(minLength: 0)

                VStack(spacing: 2) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 10))

                    Text(duration)
                        .font(.system(size: 7, weight: .regular))
                        .opacity(0.7)
                }
                .frame(width: 32)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(width: brickWidth, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.white.opacity(colorScheme == .dark ? opacity * 0.5 : opacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(
                        .white.opacity(colorScheme == .dark ? opacity * 0.7 : opacity * 1.2),
                        lineWidth: 0.5
                    )
            )
            .foregroundStyle(.white.opacity(opacity + 0.2))
        }
    }
}

// MARK: - Preview

#Preview("As Standalone View") {
    IntroducingEpisodesView(appMemory: AppPersistentMemory.shared)
}

#Preview("As Sheet") {
    VStack {
        Text("Stuff")
        Text("Stuff")
        Text("Stuff")
    }
    .sheet(isPresented: .constant(true)) {
        IntroducingEpisodesView(appMemory: AppPersistentMemory.shared)
    }
}
