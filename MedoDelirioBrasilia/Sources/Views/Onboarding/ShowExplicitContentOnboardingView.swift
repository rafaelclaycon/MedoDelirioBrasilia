//
//  ShowExplicitContentOnboardingView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/02/23.
//

import SwiftUI

struct ShowExplicitContentOnboardingView: View {

    @Binding var isBeingShown: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 40) {
                Image(systemName: "mouth.fill")
                   .resizable()
                   .scaledToFit()
                   .frame(width: 100)
                   .foregroundStyle(Color.red)
                   .overlay(alignment: .bottomLeading) {
                       HStack {
                           Image(systemName: "exclamationmark.bubble.fill")
                               .font(.system(size: 50))
                               .scaleEffect(x: -1, y: 1)
                               .foregroundStyle(Color.blue)
                               .offset(x: -60, y: -40)

                           Image(systemName: "asterisk")
                               .font(.system(size: 40))
                               .foregroundStyle(Color.orange)
                               .offset(x: 26, y: 30)
                       }
                       .overlay {
                           HStack {
                               Text("🦎")
                                   .font(.system(size: 50))
                                   .foregroundStyle(Color.orange)
                                   .offset(x: -55, y: 50)
                               Text("🐍")
                                   .font(.system(size: 50))
                                   .scaleEffect(x: -1, y: 1)
                                   .foregroundStyle(Color.blue)
                                   .offset(x: 45, y: -40)
                           }
                       }
                   }
                   .padding([.top, .bottom], 40)

                Text(verbatim: "Po**a,  c*r*lho")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)

                Text("Muitos sons contém palavrões e você pode optar por vê-los ou não.")
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .center, spacing: 22) {
                Button {
                    UserSettings.setShowExplicitContent(to: true)
                    isBeingShown.toggle()
                } label: {
                    Text("Mostrar Sons Explícitos")
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .tint(.accentColor)
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 15))

                Button {
                    isBeingShown.toggle()
                } label: {
                    Text("Não Mostrar Sons Explícitos")
                }
                .foregroundColor(.blue)

                Text("Você pode mudar isso mais tarde nas Configurações do app.")
                    .multilineTextAlignment(.center)
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            .background(Color.systemBackground)
        }
    }
}

#Preview {
    NavigationView {
        ShowExplicitContentOnboardingView(isBeingShown: .constant(true))
    }
}
