//
//  MusicGenre.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/09/22.
//

import Foundation

enum MusicGenre: Int, CaseIterable, Identifiable, Codable {

    case all, arrocha, electronic, funk, undefined, house, jingle, marchinha, metal, mpb, pagode, pisero, pop, rock, samba, sertanejo, tecno, variousGenres
    
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
        case .rock:
            return "Rock"
        // 14
        case .samba:
            return "Samba"
        // 15
        case .sertanejo:
            return "Sertanejo"
        // 16
        case .tecno:
            return "Tecno"
        // 17
        case .variousGenres:
            return "Vários gêneros"
        }
    }

}
