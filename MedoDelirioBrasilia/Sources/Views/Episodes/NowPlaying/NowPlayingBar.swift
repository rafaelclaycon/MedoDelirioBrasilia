//
//  NowPlayingBar.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 06/12/24.
//

import SwiftUI

struct NowPlayingBar<Content: View>: View {

    var content: Content

    //@State var showBar: Bool = player != nil ? ((player!.state.activity == .playing) || (player!.state.activity == .paused)) : false
    let showBar: Bool = true
    @State private var showNowPlayingScreen: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            content

            if showBar {
                HStack {
                    Button(action: {}) {
                        Image("Cover")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .shadow(radius: 1, x: 0, y: 2)
                            .padding(.leading)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "gobackward")
                            .font(.headline)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {}) {
                        Image(systemName: "play.circle.fill")
                            .font(.largeTitle)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)

                    Button(action: {}) {
                        Image(systemName: "goforward")
                            .font(.headline)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "list.triangle")
                            .font(.headline)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 20)
                }
                .frame(height: 65)
                .background {
                    Rectangle()
                        .fill(.background)
                        .shadow(radius: 3, x: 0, y: -0.5)
                }
                .onTapGesture {
                    self.showNowPlayingScreen.toggle()
                }
                //.fullScreenCover(isPresented: $showNowPlayingScreen, content: NowPlayingView.init)
            }
        }
    }
}

//#Preview {
//    NowPlayingBar()
//}
