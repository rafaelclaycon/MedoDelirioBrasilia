//
//  WhatsNewView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/02/23.
//

import SwiftUI

struct WhatsNewView: View {

    @Binding var isBeingShown: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 40) {
                Image("IconePadrao")
                   .resizable()
                   .scaledToFit()
                   .frame(width: 100)
                   .cornerRadius(20)
                   .shadow(radius: 2, y: 2)
                   .overlay(alignment: .bottomLeading) {
                       Text("💪")
                           .font(.system(size: 70))
                           .offset(x: -45, y: 10)
                   }

                Text("O App Evoluiu")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)

                Text("A partir de agora os conteúdos serão sincronizados com o servidor.\n\nNovos sons e música aparecerão muito mais rápido e sem necessidade de abrir a App Store para atualizar.")
                    .multilineTextAlignment(.center)

                Button {
                    AppPersistentMemory.setHasSeen70WhatsNewScreen(to: true)
                    dismiss()
                } label: {
                    Text("Bora!")
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .tint(.accentColor)
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 15))
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
        }
    }
}

struct WhatsNewView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView(isBeingShown: .constant(true))
    }
}
