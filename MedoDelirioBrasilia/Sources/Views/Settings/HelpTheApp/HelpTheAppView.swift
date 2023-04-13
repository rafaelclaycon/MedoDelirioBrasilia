//
//  LargeCreatorView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/06/22.
//

import SwiftUI
import MarqueeText

struct HelpTheAppView: View {

    @Binding var donorNames: String
    @Binding var imageIsSelected: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 18) {
            HStack(spacing: 20) {
                Image("creator")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 80)
                    .onTapGesture {
                        withAnimation {
                            imageIsSelected.toggle()
                        }
                    }
                
                Text("Rafael aqui, criador do app Medo e Delírio para iPhone, iPad e Mac.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 15)
            }
            
            VStack(alignment: .leading, spacing: 18) {
                Text("Esse trabalho é voluntário e envolve custos mensais com servidor (~R$ 30). Toda contribuição é bem-vinda!")
                    .fixedSize(horizontal: false, vertical: true)
                
                if donorNames.isEmpty == false {
                    Text("**Últimas contribuições:**")
                    
                    MarqueeText(text: donorNames,
                                font: UIFont.preferredFont(forTextStyle: .body),
                                leftFade: 16,
                                rightFade: 16,
                                startDelay: 1)
                        .padding(.bottom, -5)
                }
            }
        }
    }

}

struct BegForMoneyView_Previews: PreviewProvider {

    static var previews: some View {
        HelpTheAppView(donorNames: .constant("Roberto B. E. T.     Carolina P. L.     Pedro O. R.     Maria Augusta M. C.     Luiz Fernando L. F."), imageIsSelected: .constant(false))
    }

}
