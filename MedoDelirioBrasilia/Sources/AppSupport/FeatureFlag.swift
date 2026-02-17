//
//  FeatureFlag.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import Foundation

enum FeatureFlag: String, CaseIterable {

    case episodes = "featureFlag_episodes"

    var displayName: String {
        switch self {
        case .episodes:
            return "Episódios"
        }
    }

    var description: String {
        switch self {
        case .episodes:
            return "Habilita a aba de Episódios com reprodutor de áudio e integração com FeedKit."
        }
    }

    static func isEnabled(_ flag: FeatureFlag) -> Bool {
        UserDefaults.standard.bool(forKey: flag.rawValue)
    }

    static func setEnabled(_ flag: FeatureFlag, to value: Bool) {
        UserDefaults.standard.set(value, forKey: flag.rawValue)
    }
}
