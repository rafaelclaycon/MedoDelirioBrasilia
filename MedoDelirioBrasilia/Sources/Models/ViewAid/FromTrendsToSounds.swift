//
//  FromTrendsToSounds.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/10/22.
//

import SwiftUI

//class FromTrendsToSounds: Identifiable, Codable {
//
//    var id = UUID()
//    var soundIdToGoTo: String = .empty
//
//}

@MainActor class FromTrendsToSounds: ObservableObject {

    @Published var soundIdToGoTo: String = .empty

}
