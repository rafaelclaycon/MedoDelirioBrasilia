//
//  Int+Extensions.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 06/02/23.
//

import Foundation

extension Int {
    
    func asString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(self)) ?? .empty
    }
    
}
