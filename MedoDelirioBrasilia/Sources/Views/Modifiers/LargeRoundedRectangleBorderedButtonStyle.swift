//
//  LargeRoundedRectangleBorderedButtonStyle.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 19/08/23.
//

import SwiftUI

struct LargeRoundedRectangleBorderedButtonStyle: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        content
            .tint(color)
            .controlSize(.large)
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle)
    }
}

extension Button {
    func largeRoundedRectangleBordered(colored color: Color) -> some View {
        self.modifier(LargeRoundedRectangleBorderedButtonStyle(color: color))
    }
}
