//
//  Version9WhatsNewView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 25/04/25.
//

import SwiftUI

struct Version9WhatsNewView: View {

    let appMemory: AppPersistentMemoryProtocol

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: .spacing(.xxxLarge)) {
                    VStack(spacing: 0) {
                        Text("Novidades da Versão 9")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 30) {
                        ItemView(
                            image: Image(systemName: "square.fill.and.line.vertical.and.square.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: .spacing(.xxxLarge))
                                .foregroundStyle(.green),
                            title: "Novo Seletor de Modo",
                            message: Text("Navegue com conforto pela parte superior do app para trocar entre Favoritos, Pastas e Autores.")
                        )

                        ItemView(
                            image: VStack {
                                Image(systemName: "music.note")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: .spacing(.xxxLarge))
                                    .foregroundStyle(.green)
                            }.frame(width: .spacing(.xxxLarge)),
                            title: "Músicas Em Destaque",
                            message: Text("Agora você encontra Sons e Músicas **juntos** na grade principal de conteúdos.")
                        )

                        ItemView(
                            image: Image(systemName: "folder.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: .spacing(.xxxLarge))
                                .foregroundStyle(.purple)
                            ,
                            title: "Pastas com Cheirinho de Novo",
                            message: Text("As pastas contam com um novo visual, inspirado pelo Mac OS X Leopard.")
                        )
                    }
                }
                .padding(.top, .spacing(.huge))
                .padding(.horizontal, .spacing(.xxLarge))
            }
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .center) {
                    Button {
                        appMemory.hasSeenVersion9WhatsNewScreen(true)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Popcorn and ice cream sellers")
                                .bold()
                            Spacer()
                        }
                    }
                    .largeRoundedRectangleBorderedProminent(colored: .green)

                    Spacer()
                        .frame(height: 40)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.systemBackground)
            }
        }
    }
}

// MARK: - Subviews

extension Version9WhatsNewView {

    struct ItemView<ImageView: View>: View {

        let image: ImageView
        let title: String
        let message: Text

        var body: some View {
            HStack(spacing: .spacing(.large)) {
                image

                VStack(alignment: .leading, spacing: .spacing(.xxSmall)) {
                    Text(title)
                        .bold()

                    message
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Text("Stuff")
        Text("Stuff")
        Text("Stuff")
    }
    .sheet(isPresented: .constant(true)) {
        Version9WhatsNewView(appMemory: AppPersistentMemory())
    }
}
