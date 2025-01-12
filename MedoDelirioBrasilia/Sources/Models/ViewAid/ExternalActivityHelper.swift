//
//  ExternalActivityHelper.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 23/09/24.
//

import Foundation

class ExternalActivityHelper: ObservableObject {

    @Published var soundIdToPlay: String = ""
    @Published var soundIdToHighlight: String = ""
}
