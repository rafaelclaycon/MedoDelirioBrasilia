//
//  DonorView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/23.
//

import SwiftUI

struct DonorView: View {

    let donor: Donor

    private var text: String {
        if donor.hasDonatedBefore {
            return "\(donor.name)  ⭐️"
        } else if donor.isRecurringDonor30OrOver ?? false {
            return "✨  \(donor.name)  ✨"
        } else {
            return donor.name
        }
    }

    private var border: Color {
        if donor.hasDonatedBefore {
            return .primary.opacity(0.7)
        } else if
            (donor.isRecurringDonorBelow30 ?? false) ||
            (donor.isRecurringDonor30OrOver ?? false)
        {
            return .red
        } else {
            return .primary.opacity(0.3)
        }
    }

    private var borderWidth: CGFloat {
        if
            donor.hasDonatedBefore ||
            (donor.isRecurringDonorBelow30 ?? false) ||
            (donor.isRecurringDonor30OrOver ?? false)
        {
            return 2
        } else {
            return 1.2
        }
    }

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Text(text)
            .foregroundColor(.primary)
            .bold()
            .padding(.horizontal, .spacing(.medium))
            .padding(.vertical, .spacing(.xSmall))
            .background {
                RoundedRectangle(cornerRadius: 99)
                    .fill(.gray)
                    .opacity(colorScheme == .dark ? 0.5 : 0.05)
                    .overlay(
                        RoundedRectangle(cornerRadius: 99)
                            .stroke(border, lineWidth: borderWidth)
                    )
            }
    }
}

#Preview {
    VStack(spacing: 50) {
        DonorView(donor: Donor(name: "Bruno P. G. P."))
        DonorView(donor: Donor(name: "Clarissa P. S.", hasDonatedBefore: true))
        DonorView(donor: Donor(name: "Douglas B.", isRecurringDonorBelow30: true))
        DonorView(donor: Donor(name: "Pedro Henrique B. P.", isRecurringDonor30OrOver: true))
    }
}
