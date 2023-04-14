//
//  Donor.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/23.
//

import Foundation

struct Donor {
    
    let name: String
    let isRepeatDonor: Bool
    
    init(name: String, isRecurringDonor: Bool = false) {
        self.name = name
        self.isRepeatDonor = isRecurringDonor
    }
}
