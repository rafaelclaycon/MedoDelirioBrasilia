//
//  LargeCapsuleBorderedProminentButtonStyle.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 17/06/23.
//

import SwiftUI

struct LargeCapsuleBorderedProminentButtonStyle: ViewModifier {
    
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .tint(color)
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
    }
}

extension Button {
    
    func borderedProminentButton(colored color: Color) -> some View {
        self.modifier(LargeCapsuleBorderedProminentButtonStyle(color: color))
    }
}
