//
//  Double+Extensions.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 06/02/23.
//

import Foundation

extension Double {

    func asString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second, .nanosecond]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: self) ?? .empty
    }

}
