//
//  MiniCapsuleButtonStyle.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 19/09/23.
//

import SwiftUI

struct MiniCapsuleButtonStyle: ViewModifier {

    var color: Color

    func body(content: Content) -> some View {
        content
            .tint(color)
            .controlSize(.small)
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
    }
}

extension Button {

    func miniCapsule(colored color: Color) -> some View {
        self.modifier(MiniCapsuleButtonStyle(color: color))
    }
}
