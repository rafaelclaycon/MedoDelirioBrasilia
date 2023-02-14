//
//  SelectMultipleSymbol.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/02/23.
//

import SwiftUI

struct SelectMultipleSymbol: View {
    
    private let circleSide: CGFloat = 24.0
    
    var body: some View {
        ZStack {
            Image(systemName: "square.grid.3x3.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 38)
                .foregroundColor(.green)
                .opacity(0.6)
            
            ZStack {
                Circle()
                    .fill(Color.systemBackground)
                    .frame(width: circleSide, height: circleSide)
                
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26)
                    .foregroundColor(.green)
            }
            .padding(.leading, 20)
            .padding(.top, 20)
        }
    }
    
}

struct SelectMultipleSymbol_Previews: PreviewProvider {
    
    static var previews: some View {
        SelectMultipleSymbol()
    }
    
}
