//
//  LargeCapsuleBorderedButtonStyle.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 17/06/23.
//

import SwiftUI

struct LargeCapsuleBorderedButtonStyle: ViewModifier {
    
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .tint(color)
            .controlSize(.large)
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
    }
}

extension Button {
    
    func borderedButton(colored color: Color) -> some View {
        self.modifier(LargeCapsuleBorderedButtonStyle(color: color))
    }
}
