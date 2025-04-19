//
//  WordPluralization.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 02/02/23.
//

import Foundation

enum WordPluralization {

    case singular, plural
}

extension WordPluralization {
    
    func getAddedToFolderToastText(folderName: String?) -> String {
        switch self {
        case .singular:
            return "Conteúdo adicionado à pasta \(folderName ?? "")."
        case .plural:
            return "Conteúdos adicionados à pasta \(folderName ?? "")."
        }
    }
}
