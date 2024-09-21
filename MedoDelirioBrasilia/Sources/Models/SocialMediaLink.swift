//
//  SocialMediaLink.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/09/24.
//

struct SocialMediaLink: Identifiable {

    let name: String
    let imageName: String
    let link: String

    var id: String {
        self.name
    }
}
