//
//  TipView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 04/07/22.
//

import SwiftUI

struct TipView: View {

    @Environment(\.colorScheme) var colorScheme
    @Binding var text: String
    @Binding var didTapClose: Bool
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        didTapClose = true
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15)
                            .foregroundColor(colorScheme == .dark ? .primary : .gray)
                    }
                    .padding(.trailing)
                }
                Spacer()
            }
            
            HStack(spacing: 20) {
                Image(systemName: "lightbulb")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 7) {
                    Text("Dica")
                        .font(.headline)
                    
                    Text(text)
                        .opacity(0.75)
                }
                
                Spacer()
            }
            .padding(.leading, 20)
        }
        .padding(.vertical)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.gray)
                .opacity(colorScheme == .dark ? 0.3 : 0.1)
        }
    }
}

struct TipView_Previews: PreviewProvider {

    static var previews: some View {
        TipView(text: .constant("Para responder a um tuíte, escolha Salvar Vídeo na tela de compartilhamento. Depois, adicione o vídeo ao seu tuíte de dentro do Twitter."), didTapClose: .constant(false))
    }
}
