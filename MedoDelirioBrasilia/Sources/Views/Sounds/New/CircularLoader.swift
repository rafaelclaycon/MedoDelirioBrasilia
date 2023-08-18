//
//  CircularLoader.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 16/08/23.
//

import SwiftUI

struct CircularLoader: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(AngularGradient(gradient: .init(colors: [.accentColor]), center: .center), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear() {
                self.isAnimating = true
            }
    }
}

struct CircularLoader_Previews: PreviewProvider {
    static var previews: some View {
        CircularLoader()
            .frame(width: 34)
    }
}
