//
//  WPStartView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 25/12/24.
//

import SwiftUI

struct WPStartView: View {

    @State private var wpPath = NavigationPath()
    @Environment(\.push) var push

    var body: some View {
        NavigationStack(path: $wpPath) {
            ScrollView {
                VStack {
                    HStack(spacing: 12) {
                        Tile(
                            symbol: "speaker.wave.3.fill",
                            text: "Sons"
                        )
                        .onTapGesture {
                            wpPath.append(WPNavigationDestination.sounds)
                        }

                        Tile(
                            symbol: "music.quarternote.3",
                            text: "Músicas"
                        )
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 30)
            }
            .navigationDestination(for: WPNavigationDestination.self) { screen in
                WPRouter(destination: screen)
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()

                    Image(systemName: "arrow.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundStyle(.white)

                    Spacer()

                    Image("logo_wp_theme")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44)
                        .padding(.horizontal)

                    Spacer()

                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundStyle(.white)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background {
                    Color.black
                }
            }
        }
        .environment(\.push, PushAction { wpPath.append($0) })
    }
}

#Preview {
    WPStartView()
}
