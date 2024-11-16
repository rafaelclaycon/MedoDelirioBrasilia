//
//  StoriesView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/10/24.
//

import SwiftUI

struct StoriesView: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text("Dashes")
                .foregroundStyle(.white)

            FirstStory()

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(.black)
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Subviews

extension StoriesView {

    struct FirstStory: View {

        @State private var isLarge = false

        var body: some View {
            VStack {
                VStack(spacing: 15) {
                    Spacer()

                    Text("Juntos doamos")
                        .font(.largeTitle)

                    Text("R$ 1.600")
                        .font(isLarge ? .system(size: 60) : .body)
                        .bold()
                        .animation(.easeInOut(duration: 0.75), value: isLarge)

                    Text("para **9 famílias** desabrigadas no Rio Grande do Sul.")
                        .font(.title)

                    Spacer()
                }
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.horizontal, 30)
            }
            .background {
                Color.green
            }
            .onAppear {
                isLarge.toggle()
            }
        }
    }

    struct SecondStory: View {

        var body: some View {
            VStack {
                VStack(spacing: 15) {
                    Spacer()

                    Text("Juntos doamos")
                        .font(.largeTitle)

                    Text("para **9 famílias** desabrigadas no Rio Grande do Sul.")
                        .font(.title)

                    Spacer()
                }
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.horizontal, 30)
            }
            .background {
                Color.green
            }
        }
    }
}

#Preview {
    StoriesView()
}

//#Preview("Show Sheet") {
//
//    struct BackgroundTestView: View {
//
//        @State private var isSheetPresented: Bool = false
//
//        var body: some View {
//            VStack(spacing: 30) {
//                Text("Background View")
//
//                Button("ShowSheet") {
//                    isSheetPresented = true
//                }
//            }
//            .fullScreenCover(isPresented: $isSheetPresented) {
//                StoriesView()
//            }
//        }
//    }
//
//    return BackgroundTestView()
//}
