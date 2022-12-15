//
//  TrendsHelper.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 14/12/22.
//

import Foundation

class TrendsHelper: ObservableObject {

    @Published var soundIdToGoTo: String = .empty
    @Published var timeIntervalToGoTo: TrendsTimeInterval? = nil

}
