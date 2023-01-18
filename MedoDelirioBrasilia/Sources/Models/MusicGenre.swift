//
//  MusicGenre.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/09/22.
//

import Foundation

enum MusicGenre: Int, CaseIterable, Identifiable, Codable {

    case all, arrocha, electronic, funk, undefined, house, jingle, marchinha, metal, mpb, pagode, pop, rock, samba, sertanejo, tecno, pisero
    
    var id: String { String(self.rawValue) }
    var name: String {
        switch self {
        case .all:
            return "Todos os gêneros"
        case .arrocha:
            return "Arrocha"
        case .electronic:
            return "Eletrônica"
        case .funk:
            return "Funk"
        case .undefined:
            return "Gênero indefinido"
        case .house:
            return "House"
        case .jingle:
            return "Jingle"
        case .marchinha:
            return "Marchinha"
        case .metal:
            return "Metal"
        case .mpb:
            return "MPB"
        case .pagode:
            return "Pagode"
        case .pop:
            return "Pop"
        case .rock:
            return "Rock"
        case .samba:
            return "Samba"
        case .sertanejo:
            return "Sertanejo"
        case .tecno:
            return "Tecno"
        case .pisero:
            return "Pisero"
        }
    }

}
