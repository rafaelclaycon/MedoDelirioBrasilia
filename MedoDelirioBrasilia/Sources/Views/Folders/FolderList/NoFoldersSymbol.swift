//
//  NoFoldersSymbol.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 21/11/22.
//

import SwiftUI

struct NoFoldersSymbol: View {

    var body: some View {
        ZStack {
            Image(systemName: "folder")
                .resizable()
                .scaledToFit()
                .frame(width: 84)
                .foregroundColor(.gray)
                .opacity(0.4)
            
            Image(systemName: "speaker.wave.2.bubble.left.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 42)
                .foregroundColor(.green)
                .opacity(0.9)
                .padding(.bottom, 70)
                .padding(.leading, 85)
            
            Image(systemName: "speaker.wave.2.bubble.left.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 38)
                .foregroundColor(.yellow)
                .padding(.top, 70)
                .padding(.trailing, 100)
            
            Image(systemName: "speaker.wave.2.bubble.left.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 24)
                .foregroundColor(.pink)
                .opacity(0.8)
                .padding(.top, 60)
                .padding(.leading, 110)
        }
    }

}

struct NoFoldersSymbol_Previews: PreviewProvider {

    static var previews: some View {
        NoFoldersSymbol()
    }

}
