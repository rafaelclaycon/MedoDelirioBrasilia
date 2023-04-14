//
//  ScrollingTagView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/23.
//

import SwiftUI

private struct ScrollingContentWidthPreferenceKey: PreferenceKey {
    
    typealias Value = CGFloat

    static var defaultValue: Value = 0.0

    static func reduce(
        value: inout Value,
        nextValue: () -> Value
    ) {
        value += nextValue()
    }
}

struct ScrollingTagView: View {
    
    @State private var textoffset = 300.0
    @State private var yTextOffset: CGFloat = 0
    @State private var donorsFrame: CGRect = .zero
    
    let donors: [Donor] = [Donor(name: "Bruno P. G. P."),
                          Donor(name: "Clarissa P. S.", isRecurringDonor: true),
                          Donor(name: "Pedro Henrique B. P.")]
    
    var body: some View {
        Color.yellow
            .opacity(0)
            .frame(height: donorsFrame.size.height)
            .overlay(alignment: .top) {
                HStack(spacing: 15) {
                    ForEach(donors, id: \.name) { donor in
                        DonorView(donor: donor)
                    }
                }
                .fixedSize()
                .measuringFrame(assign: $donorsFrame)
                .offset(x: textoffset, y: yTextOffset)
                .border(.red, width: 1)
            }
            .animation(.linear(duration: 15)
                       .repeatForever(autoreverses: false), value: textoffset)
            //.clipped()
            .onAppear {
                textoffset = -(donorsFrame.size.width * 1.5)
                yTextOffset = 0
            }
            .border(.black, width: 1)
    }
}

struct ScrollingTagView_Previews: PreviewProvider {
    
    static var previews: some View {
        ScrollingTagView()
    }
}
