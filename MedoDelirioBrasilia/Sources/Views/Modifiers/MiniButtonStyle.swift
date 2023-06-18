//
//  MiniButtonStyle.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 17/06/23.
//

import SwiftUI

struct MiniButtonStyle: ViewModifier {
    
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .tint(color)
            .controlSize(.mini)
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle)
    }
}

extension Button {
    
    func miniButton(colored color: Color) -> some View {
        self.modifier(MiniButtonStyle(color: color))
    }
}
