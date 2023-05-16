//
//  SyncProgressView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 10/05/23.
//

import SwiftUI

struct SyncProgressView: View {
    
    @Binding var currentAmount: Double
    @Binding var totalAmount: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Atualizando dados... (\(Int(currentAmount))/\(Int(totalAmount)))")
            
            ProgressView(value: currentAmount, total: totalAmount)
        }
        .frame(height: 80)
        .padding(.horizontal, 28)
    }
}

struct SyncProgressView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            SyncProgressView(currentAmount: .constant(2), totalAmount: .constant(5))
            SyncProgressView(currentAmount: .constant(0), totalAmount: .constant(1))
            SyncProgressView(currentAmount: .constant(7), totalAmount: .constant(35))
        }
    }
}
