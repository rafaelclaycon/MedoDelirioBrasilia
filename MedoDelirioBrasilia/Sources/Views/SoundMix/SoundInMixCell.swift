//
//  SoundInMixCell.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 05/02/23.
//

import SwiftUI

struct SoundInMixCell: View {

    @State var soundInMix: SoundInMix
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(soundInMix.color)
                .frame(height: UIDevice.is4InchDevice ? 120 : 84)
            
            HStack {
                NumberBadgeView(number: "\(soundInMix.positionOnList)")
                    .foregroundColor(.primary)
                    .padding(.trailing, 10)
                
                Text(soundInMix.sound.title)
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

struct SoundInMixCell_Previews: PreviewProvider {

    static var previews: some View {
        SoundInMixCell(soundInMix: SoundInMix(sound: Sound(title: "Bem-vindo ao devido processo legal?"), positionOnList: 1, color: .pastelYellow))
    }

}
