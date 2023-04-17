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
                           Donor(name: "Pedro Henrique B. P."),
                           Donor(name: "Antônio Felipe F. S.")]
    
//    let donors: [Donor] = [Donor(name: "Bruno P. G. P."),
//                          Donor(name: "Clarissa P. S.")]
    
    private var hasAnyRepeatDonor: Bool {
        let filteredDonors = donors.filter({ $0.isRepeatDonor == true })
        return filteredDonors.count > 0
    }
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(donors, id: \.name) { donor in
                DonorView(donor: donor)
                    .padding(.bottom, hasAnyRepeatDonor ? 16 : 0)
            }
        }
    }
}

struct ScrollingTagView_Previews: PreviewProvider {
    
    static var previews: some View {
        ScrollingTagView()
    }
}
