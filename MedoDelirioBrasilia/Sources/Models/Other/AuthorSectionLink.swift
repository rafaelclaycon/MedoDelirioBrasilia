//
//  AuthorSectionLink.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/09/24.
//

import SwiftUI

enum AuthorSectionLinkType {

    case blog, socialMedia
}

struct AuthorSectionLink: Identifiable {

    let name: String
    let imageName: String
    let link: String
    let color: Color
    let type: AuthorSectionLinkType

    var id: String {
        self.imageName
    }
}
