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
    
    @State private var offSet: CGFloat = 0
    @State private var contentWidth: CGFloat = 0
    
    let donors: [Donor] = [Donor(name: "Bruno P. G. P."),
                          Donor(name: "Clarissa P. S.", isRecurringDonor: true),
                          Donor(name: "Pedro Henrique B. P.")]
    
//    let donors: [Donor] = [Donor(name: "Bruno P. G. P."),
//                          Donor(name: "Clarissa P. S.")]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack(spacing: 15) {
                    ForEach(donors, id: \.name) { donor in
                        DonorView(donor: donor)
                            .anchorPreference(key: ScrollingContentWidthPreferenceKey.self, value: .bounds) { anchor in
                                print("HERMIONE geometry[anchor].width: \(geometry[anchor].width)")
                                return geometry[anchor].width
                            }
                    }
                }
                .offset(x: geometry.size.width + abs(contentWidth - geometry.size.width))
                .offset(x: offSet)
                .padding()
                .animation(.linear(duration: 12.0).repeatForever(autoreverses: false), value: offSet)  // Some function of the width of the screen and the content
            }
            .frame(width: geometry.size.width, alignment: .center)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .onAppear {
                print("HERMIONE geometry.size.width: \(geometry.size.width)")
                offSet = -geometry.size.width - contentWidth - abs(contentWidth - geometry.size.width)
            }
            .onPreferenceChange(ScrollingContentWidthPreferenceKey.self) { newWidth in
                self.contentWidth = newWidth
            }
        }
        .scenePadding()
    }
}

struct ScrollingTagView_Previews: PreviewProvider {
    
    static var previews: some View {
        ScrollingTagView()
    }
}
