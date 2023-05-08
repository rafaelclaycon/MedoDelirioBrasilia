//
//  ScrollingTagView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/23.
//

import SwiftUI

struct DonorsView: View {
    
    @Binding var donors: [Donor]?
    
    private var hasAnyRepeatDonor: Bool {
        let filteredDonors = donors?.filter({ $0.hasDonatedBefore == true })
        return filteredDonors?.count ?? 0 > 0
    }
    
    var body: some View {
        if donors == nil {
            EmptyView()
        } else {
            HStack(spacing: 15) {
                ForEach(donors!, id: \.name) { donor in
                    DonorView(donor: donor)
                        .padding(.bottom, hasAnyRepeatDonor ? 16 : 0)
                }
            }
        }
    }
}

struct ScrollingTagView_Previews: PreviewProvider {
    
    static var previews: some View {
        DonorsView(donors: .constant([Donor(name: "Bruno P. G. P."),
                                      Donor(name: "Clarissa P. S.", isRecurringDonor: true),
                                      Donor(name: "Pedro Henrique B. P.")]))
    }
}
