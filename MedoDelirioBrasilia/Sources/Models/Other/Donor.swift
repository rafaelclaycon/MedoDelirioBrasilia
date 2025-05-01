//
//  Donor.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/23.
//

import Foundation

struct Donor: Codable {

    let name: String
    let hasDonatedBefore: Bool
    let isRecurringDonorBelow30: Bool?
    let isRecurringDonor30OrOver: Bool?

    var isSpecial: Bool {
        return hasDonatedBefore == true || isRecurringDonorBelow30 == true || isRecurringDonor30OrOver == true
    }

    init(
        name: String,
        hasDonatedBefore: Bool = false,
        isRecurringDonorBelow30: Bool? = false,
        isRecurringDonor30OrOver: Bool? = false
    ) {
        self.name = name
        self.hasDonatedBefore = hasDonatedBefore
        self.isRecurringDonorBelow30 = isRecurringDonorBelow30
        self.isRecurringDonor30OrOver = isRecurringDonor30OrOver
    }
}
