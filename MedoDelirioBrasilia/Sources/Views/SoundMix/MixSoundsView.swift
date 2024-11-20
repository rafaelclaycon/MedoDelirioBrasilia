//
//  MixSoundsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 04/02/23.
//

import SwiftUI

struct MixSoundsView: View {

    let sounds: [Sound]

    private func getRandomColor() -> Color {
        let colors: [Color] = [.pastelPurple, .pastelBabyBlue, .pastelBrightGreen, .pastelYellow, .pastelOrange, .pastelPink, .pastelGray, .pastelRoyalBlue, .pastelMutedGreen, .pastelRed, .pastelBeige]
        return colors.randomElement()!
    }

    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(spacing: 80) {
                        //if helper.sounds.count > 0 {
                            LazyVStack {
                                ForEach(sounds.indices, id: \.self) { i in
                                    SoundInMixCell(soundInMix: SoundInMix(sound: sounds[i], positionOnList: i + 1, color: getRandomColor()))
                                }
                            }
                            .padding(.all)
                        //}
                        
                        Button {
                            print("Play")
                        } label: {
                            Image(systemName: "play.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 50)
                                .foregroundColor(.primary)
                        }
                        
                        Button {
                            print("Share")
                        } label: {
                            HStack(spacing: 25) {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 25)
                                
                                Text("Compartilhar")
                                    .font(.headline)
                            }
                            .padding(.horizontal, 25)
                        }
                        .tint(.accentColor)
                        .controlSize(.large)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                    }
                    .navigationTitle("Misturar Sons")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(leading:
                        Button("Fechar") {
                            dismiss()
                        }
                    )
                }
            }
        }
    }

}

#Preview {
    MixSoundsView(sounds: [])
}
