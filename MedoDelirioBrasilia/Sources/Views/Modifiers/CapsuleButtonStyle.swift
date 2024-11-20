//
//  CapsuleButtonStyle.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 19/09/23.
//

import SwiftUI

struct CapsuleButtonStyle: ViewModifier {

    var color: Color

    func body(content: Content) -> some View {
        content
            .tint(color)
            .controlSize(.regular)
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
    }
}

extension Button {

    func capsule(colored color: Color) -> some View {
        self.modifier(CapsuleButtonStyle(color: color))
    }
}
