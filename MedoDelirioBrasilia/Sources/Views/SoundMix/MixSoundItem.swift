//
//  MixSoundItem.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 05/02/23.
//

import SwiftUI

struct MixSoundItem: View {

    let mixSound: MixSound

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.gray)
                .frame(height: 84)
            
            HStack {
                NumberBadgeView(number: "\(mixSound.position)", showBackgroundCircle: false)
                    .foregroundColor(.primary)
                    .padding(.trailing, 10)
                
                Text(mixSound.sound.title)
                    .foregroundColor(.primary)
                    .bold()
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .padding(.leading, 5)
                
                Spacer()
                
                Image(systemName: "line.3.horizontal")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.primary)
                    .frame(height: 14)
                    .opacity(0.5)
                    .padding(.trailing, 5)
            }
            .padding(.leading)
            .padding(.trailing)
        }
    }

}

#Preview {
    MixSoundItem(
        mixSound: MixSound(
            position: 1,
            sound: Sound(title: "Bem-vindo ao devido processo legal?")
        )
    )
}
