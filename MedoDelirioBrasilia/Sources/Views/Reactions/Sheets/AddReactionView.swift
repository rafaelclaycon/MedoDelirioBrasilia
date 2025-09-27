//
//  AddReactionView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 04/05/24.
//

import SwiftUI

struct AddReactionView: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 40) {
                    VStack(alignment: .center, spacing: 20) {
                        Text("🌎")
                            .font(.system(size: 86))

                        Text("Medo e Delírio Somos Nozes")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                    }

                    Text("Reações é um recurso colaborativo e online. As categorias são as mesmas para todos os usuários.\n\nPensou numa categoria nova diferente? Acha que uma vírgula não está na categoria certa ou que faltam vírgulas? Envie-me um e-mail.")
                        .multilineTextAlignment(.center)

                    Button {
                        Task {
                            await Mailman.openDefaultEmailApp(
                                subject: Shared.Email.Reactions.suggestChangesSubject,
                                body: Shared.Email.Reactions.suggestChangesBody
                            )
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Enviar e-mail")
                            Spacer()
                        }
                    }
                    .borderedProminentButton(colored: .green)
                }
                .padding(.vertical)
                .padding(.horizontal, 20)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButton {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AddReactionView()
}
