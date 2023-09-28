//
//  CenterAlignedLabelStyle.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/09/23.
//

import SwiftUI

struct CenterAlignedLabelStyle: LabelStyle {

    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center) {
            configuration.icon
            configuration.title
        }
    }
}

extension LabelStyle where Self == CenterAlignedLabelStyle {
    static var centerAligned: Self { .init() }
}
