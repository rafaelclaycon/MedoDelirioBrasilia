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
        ZStack(alignment: .top) {
            Text(donor.name)
                .foregroundColor(.primary)
                .bold()
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 9).fill(.gray).opacity(colorScheme == .dark ? 0.5 : 0.1))
            
            if donor.isRepeatDonor {
                Text("⭐️ RECORRENTE")
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .bold()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 9).fill(.primary))
                    .offset(y: 25)
            }
        }
    }
}

struct DonorView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack(spacing: 50) {
            DonorView(donor: Donor(name: "Bruno P. G. P."))
            DonorView(donor: Donor(name: "Clarissa P. S.", isRecurringDonor: true))
            DonorView(donor: Donor(name: "Douglas B."))
            DonorView(donor: Donor(name: "Pedro Henrique B. P."))
        }
    }
}
