//
//  Donor.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/23.
//

import Foundation

struct Donor: Decodable {
    
    let name: String
    let hasDonatedBefore: Bool
    
    init(name: String, isRecurringDonor: Bool = false) {
        self.name = name
        self.hasDonatedBefore = isRecurringDonor
    }
}
