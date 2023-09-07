//
//  PleaseAnswerTheSurveyBanner.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 07/09/23.
//

import SwiftUI

struct PleaseAnswerTheSurveyBanner: View {

    @Binding var isBeingShown: Bool

    @Environment(\.colorScheme) var colorScheme

    private let color: Color = .darkerGreen

    private var foregroundColor: Color {
        if colorScheme == .dark {
            return .primary
        } else {
            return color
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "checkmark.bubble")
                .resizable()
                .scaledToFit()
                .frame(height: 36)
                .foregroundColor(foregroundColor)

            VStack(alignment: .leading, spacing: 8) {
                Text("Olá, querido(a) usuário(a)")
                    .foregroundColor(foregroundColor)
                    .bold()

                Text("Esta versão Beta conta com um questionário para me ajudar a entender a sua experiência (e, de quebra, ganhar nota no meu TCC). Por favor, tire 3 minutos do seu rico tempo e responda-o.")
                    .foregroundColor(.primary)
                    .opacity(0.8)
                    .font(.callout)

                Button {
                    OpenUtility.open(link: surveyLink)
                } label: {
                    Text("Responder questionário")
                }
                .tint(foregroundColor)
                .controlSize(.regular)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
                .padding(.top, 2)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(color)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                AppPersistentMemory.setHasSeenBetaSurveyBanner(to: true)
                isBeingShown = false
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(foregroundColor)
            }
            .padding()
        }
    }
}

struct PleaseAnswerTheSurveyBanner_Previews: PreviewProvider {
    static var previews: some View {
        PleaseAnswerTheSurveyBanner(isBeingShown: .constant(true))
            .padding()
    }
}
