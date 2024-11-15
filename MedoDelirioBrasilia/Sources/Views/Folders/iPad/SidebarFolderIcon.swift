//
//  SidebarFolderIcon.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/07/22.
//

import SwiftUI

struct SidebarFolderIcon: View {

    let symbol: String
    let backgroundColor: Color
    var size: CGFloat = 40

    var body: some View {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(backgroundColor)
            .frame(width: size, height: size)
            .overlay {
                Text(symbol)
            }
    }
}

// MARK: - Preview

#Preview {
    SidebarFolderIcon(
        symbol: "😎",
        backgroundColor: .pastelBabyBlue
    )
}
