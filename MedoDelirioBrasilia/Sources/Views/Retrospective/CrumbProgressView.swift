//
//  CrumbProgressView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 10/11/24.
//

import SwiftUI

struct CrumbProgressView: View {

    var progress: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundStyle(Color.white.opacity(0.3))
                    .cornerRadius(5)

                Rectangle()
                    .frame(width: geometry.size.width * self.progress, alignment: .leading)
                    .foregroundStyle(Color.white.opacity(0.9))
                    .cornerRadius(5)
            }
        }
    }
}

#Preview {
    CrumbProgressView(progress: 50)
}
