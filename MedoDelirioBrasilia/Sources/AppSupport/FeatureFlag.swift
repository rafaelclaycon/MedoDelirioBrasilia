//
//  FeatureFlag.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import Foundation

enum FeatureFlag: String, CaseIterable {

    case episodeNotifications = "featureFlag_episodeNotifications"

    var displayName: String {
        switch self {
        case .episodeNotifications:
            return "Notificações de Novos Episódios"
        }
    }

    var description: String {
        switch self {
        case .episodeNotifications:
            return "Exibe a opção de receber notificações quando novos episódios forem publicados."
        }
    }

    static func isEnabled(_ flag: FeatureFlag) -> Bool {
        UserDefaults.standard.bool(forKey: flag.rawValue)
    }

    static func setEnabled(_ flag: FeatureFlag, to value: Bool) {
        UserDefaults.standard.set(value, forKey: flag.rawValue)
    }
}
