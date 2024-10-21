//
//  DonorView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/23.
//

import SwiftUI

struct DonorView: View {

    @State var donor: Donor
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            Text(donor.name)
                .foregroundColor(.primary)
                .bold()
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 9).fill(.gray).opacity(colorScheme == .dark ? 0.5 : 0.1))

            if donor.hasDonatedBefore {
                SpecialDonorTag(text: "⭐️  JÁ DOOU ANTES", backgroundColor: .primary)
            } else if donor.isRecurringDonorBelow30 ?? false {
                SpecialDonorTag(text: "RECORRENTE", backgroundColor: .red)
            } else if donor.isRecurringDonor30OrOver ?? false {
                SpecialDonorTag(text: "✨RECORRENTE+✨", backgroundColor: .red)
            }
        }
        .fixedSize()
    }
}

extension DonorView {

    struct SpecialDonorTag: View {

        let text: String
        let backgroundColor: Color

        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            Text(text)
                .font(.caption)
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .bold()
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(RoundedRectangle(cornerRadius: 9).fill(backgroundColor))
                .offset(y: 22)
        }
    }
}

struct DonorView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack(spacing: 50) {
            DonorView(donor: Donor(name: "Bruno P. G. P."))
            DonorView(donor: Donor(name: "Clarissa P. S.", hasDonatedBefore: true))
            DonorView(donor: Donor(name: "Douglas B."))
            DonorView(donor: Donor(name: "Pedro Henrique B. P."))
        }
    }
}
