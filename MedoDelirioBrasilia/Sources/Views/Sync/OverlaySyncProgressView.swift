//
//  OverlaySyncProgressView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 29/05/23.
//

import SwiftUI

struct OverlaySyncProgressView: View {

    @Binding var message: String
    @Binding var currentValue: Double
    @Binding var totalValue: Double

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 6) {
                Text(message)
                    .multilineTextAlignment(.center)

                ProgressView("", value: currentValue, total: totalValue)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 28)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
            }
            .frame(width: 280)
        }
    }
}

struct OverlaySyncProgressView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            OverlaySyncProgressView(message: .constant("Atualizando dados..."), currentValue: .constant(0), totalValue: .constant(1))
        }
    }
}
