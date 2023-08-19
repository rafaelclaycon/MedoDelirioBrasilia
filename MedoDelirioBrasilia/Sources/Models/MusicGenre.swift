//
//  MusicGenre.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/09/22.
//

import Foundation

enum MusicGenre: String, CaseIterable, Identifiable, Codable {
    case all, arrocha, electronic, funk, undefined, house, jingle, lambada, marchinha, metal, mpb, pagode, pisero, pop, reggae, rock, samba, sertanejo, tecno, variousGenres, tvIntro
    
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
        case .lambada:
            return "Lambada"
        case .marchinha:
            return "Marchinha"
        case .metal:
            return "Metal"
        case .mpb:
            return "MPB"
        case .pagode:
            return "Pagode"
        case .pisero:
            return "Pisero"
        case .pop:
            return "Pop"
        case .reggae:
            return "Reggae"
        case .rock:
            return "Rock"
        case .samba:
            return "Samba"
        case .sertanejo:
            return "Sertanejo"
        case .tecno:
            return "Tecno"
        case .variousGenres:
            return "Vários gêneros"
        case .tvIntro:
            return "Vinheta"
        }
    }
}
