//
//  MusicGenre.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/09/22.
//

import Foundation

enum MusicGenre: String, CaseIterable, Identifiable, Codable {

    case all, arrocha, electronic, funk, undefined, house, jingle, marchinha, metal, mpb, pagode, pisero, pop, reggae, rock, salsa, samba, sertanejo, tecno, variousGenres, tvIntro
    
    var id: String { String(self.rawValue) }
    var name: String {
        switch self {
        // 0
        case .all:
            return "Todos os gêneros"
        // 1
        case .arrocha:
            return "Arrocha"
        // 2
        case .electronic:
            return "Eletrônica"
        // 3
        case .funk:
            return "Funk"
        // 4
        case .undefined:
            return "Gênero indefinido"
        // 5
        case .house:
            return "House"
        // 6
        case .jingle:
            return "Jingle"
        // 7
        case .marchinha:
            return "Marchinha"
        // 8
        case .metal:
            return "Metal"
        // 9
        case .mpb:
            return "MPB"
        // 10
        case .pagode:
            return "Pagode"
        // 11
        case .pisero:
            return "Pisero"
        // 12
        case .pop:
            return "Pop"
        // 13
        case .reggae:
            return "Reggae"
        // 14
        case .rock:
            return "Rock"
        // 15
        case .salsa:
            return "Salsa"
        // 16
        case .samba:
            return "Samba"
        // 17
        case .sertanejo:
            return "Sertanejo"
        // 18
        case .tecno:
            return "Tecno"
        // 19
        case .variousGenres:
            return "Vários gêneros"
        // 20
        case .tvIntro:
            return "Vinheta"
        }
    }
}
