//
//  EmptyFolderView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import SwiftUI

struct EmptyFolderView: View {

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "speaker.zzz")
                .font(.system(size: 70))
                .foregroundColor(.gray)
                .frame(width: 100)
                .opacity(0.5)
            
            Text("Tá Ouvindo Isso?")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Text("Nós também não. Volte para os sons, segure em um deles e escolha Adicionar a Pasta para adicioná-lo aqui.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 15 : 40)
        }
    }

}

struct EmptyFolderView_Previews: PreviewProvider {

    static var previews: some View {
        EmptyFolderView()
    }

}
