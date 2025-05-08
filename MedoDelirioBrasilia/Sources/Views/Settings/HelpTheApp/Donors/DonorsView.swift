//
//  ScrollingTagView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/23.
//

import SwiftUI

struct DonorsView: View {

    let donors: [Donor]

    var body: some View {
        HStack(spacing: .spacing(.medium)) {
            ForEach(donors, id: \.name) { donor in
                DonorView(donor: donor)
            }
        }
        .padding(.all, .spacing(.nano))
    }
}

#Preview {
    ScrollView(.horizontal) {
        DonorsView(
            donors: [
                Donor(name: "Bruno P. G. P."),
                Donor(name: "Clarissa P. S.", hasDonatedBefore: true),
                Donor(name: "Pedro Henrique B. P."),
                Donor(name: "Steve P. J."),
                Donor(name: "Bill G.")
            ]
        )
        .padding()
    }
}
