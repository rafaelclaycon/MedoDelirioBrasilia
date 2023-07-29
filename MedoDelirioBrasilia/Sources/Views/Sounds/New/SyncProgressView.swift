//
//  SyncProgressView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 10/05/23.
//

import SwiftUI

struct SyncProgressView: View {
    
    @Binding var isBeingShown: Bool
    @Binding var currentAmount: Double
    @Binding var totalAmount: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if currentAmount == totalAmount {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    
                    Text("Dados atualizados com sucesso!")
                    
                    Spacer()
                }
            } else {
                Text("Atualizando dados... (\(Int(currentAmount))/\(Int(totalAmount)))")
                
                if totalAmount > 0 {
                    ProgressView(value: currentAmount, total: totalAmount)
                }
            }
        }
        .frame(height: 80)
        .padding(.horizontal, 28)
        .onChange(of: currentAmount) { currentAmount in
            if currentAmount == totalAmount {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    isBeingShown = false
                }
            } else if currentAmount > 0 {
                isBeingShown = true
            } else {
                isBeingShown = false
            }
        }
    }
}

struct SyncProgressView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            SyncProgressView(isBeingShown: .constant(true), currentAmount: .constant(0), totalAmount: .constant(0))
            SyncProgressView(isBeingShown: .constant(true), currentAmount: .constant(2), totalAmount: .constant(5))
            SyncProgressView(isBeingShown: .constant(true), currentAmount: .constant(0), totalAmount: .constant(1))
            SyncProgressView(isBeingShown: .constant(true), currentAmount: .constant(7), totalAmount: .constant(35))
        }
    }
}
