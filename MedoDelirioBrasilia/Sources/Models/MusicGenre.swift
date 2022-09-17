import Foundation

enum MusicGenre: Int, CaseIterable, Identifiable, Codable {

    case all, arrocha, electronic, funk, undefined, house, marchinha, metal, mpb, themeSong, pagode, pop, rock, samba, sertanejo, tecno
    
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
        case .marchinha:
            return "Marchinha"
        case .metal:
            return "Metal"
        case .mpb:
            return "MPB"
        case .themeSong:
            return "Música Tema"
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
        }
    }

}
