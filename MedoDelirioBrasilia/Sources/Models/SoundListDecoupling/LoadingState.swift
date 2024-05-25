//
//  LoadingState.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/04/24.
//

import Foundation

enum LoadingState<T> {
    case loading
    case loaded([T])
    case error(String)
}
