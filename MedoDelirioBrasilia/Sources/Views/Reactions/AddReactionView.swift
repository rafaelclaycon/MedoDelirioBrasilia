//
//  AddReactionView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 04/05/24.
//

import SwiftUI

struct AddReactionView: View {

    @State private var showPopover: Bool = false
    @State private var didCopySupportAddressOnEmailPicker: Bool = false

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

                    Text("Reações é um recurso colaborativo e online. As categorias são as mesmas para todos os usuários.\n\nPensou numa categoria nova diferente? Acha que um som não está na categoria certa ou que faltam sons? Envie-me um e-mail.")
                        .multilineTextAlignment(.center)

                    Button {
                        showPopover.toggle()
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
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .popover(isPresented: $showPopover) {
                EmailAppPickerView(
                    isBeingShown: $showPopover,
                    didCopySupportAddress: $didCopySupportAddressOnEmailPicker,
                    subject: Shared.Email.Reactions.suggestChangesSubject,
                    emailBody: Shared.Email.Reactions.suggestChangesBody
                )
            }
//            .onChange(of: showPopover) { showPopover in
//                if showPopover == false {
//                    if didCopySupportAddressOnEmailPicker {
//                        toastType = .email
//                        withAnimation {
//                            showToastView = true
//                        }
//                        TapticFeedback.success()
//
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                            withAnimation {
//                                showToastView = false
//                            }
//                        }
//
//                        didCopySupportAddressOnEmailPicker = false
//                    }
//                }
//            }
        }
    }
}

// MARK: - Preview

#Preview {
    AddReactionView()
}
