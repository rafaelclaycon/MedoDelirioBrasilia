//
//  ViewOffsetKey.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 02/02/24.
//

import Foundation

struct ViewOffsetKey: PreferenceKey {

    typealias Value = CGFloat

    static var defaultValue = CGFloat.zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
