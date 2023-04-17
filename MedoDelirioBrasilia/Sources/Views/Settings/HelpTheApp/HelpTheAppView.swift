//
//  LargeCreatorView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/06/22.
//

import SwiftUI
import MarqueeText

struct HelpTheAppView: View {

    @Binding var donors: [Donor]?
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
                
                if donors != nil, #available(iOS 16.0, *) {
                    Text("**Últimas contribuições:**")
                    
                    DonorsView(donors: $donors)
                        .padding(.bottom, 5)
                        .marquee()
                }
            }
        }
    }

}

struct HelpTheAppView_Previews: PreviewProvider {

    static var previews: some View {
        HelpTheAppView(donors: .constant([Donor(name: "Bruno P. G. P."),
                                          Donor(name: "Clarissa P. S.", isRecurringDonor: true),
                                          Donor(name: "Pedro Henrique B. P.")]),
                       imageIsSelected: .constant(false))
    }
}
