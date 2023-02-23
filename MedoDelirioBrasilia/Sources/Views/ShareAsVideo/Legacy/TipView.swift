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
    
    var roundedRectangleHeight: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            switch UIScreen.main.bounds.width {
            case 320: // iPod touch 7
                return 204
            case 375: // iPhone 8
                return 164
            case 390: // iPhone 13
                return 160
            default: // iPhone 11, 13 Pro Max
                return 150
            }
        } else {
            return 100
        }
    }
    
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
                    .padding(.top)
                    .padding(.trailing)
                }
                Spacer()
            }
            
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.gray)
                .frame(height: roundedRectangleHeight)
                .opacity(colorScheme == .dark ? 0.3 : 0.1)
            
            HStack(spacing: 20) {
                Image(systemName: "lightbulb")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
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
    }

}

struct TwitterReplyTipView_Previews: PreviewProvider {

    static var previews: some View {
        TipView(text: .constant("Para responder a um tuíte, escolha Salvar Vídeo na tela de compartilhamento. Depois, adicione o vídeo ao seu tuíte de dentro do Twitter."), didTapClose: .constant(false))
    }

}
