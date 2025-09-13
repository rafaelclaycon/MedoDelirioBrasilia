//
//  Mailman.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 15/07/22.
//

import SwiftUI

class Mailman {

    private static let supportEmail = "medodeliriosuporte@gmail.com"

    @MainActor
    static func openDefaultEmailApp(
        subject: String,
        body: String
    ) async {
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let mailToString = "mailto:\(supportEmail)?subject=\(encodedSubject)&body=\(encodedBody)"
        guard let mailToUrl = URL(string: mailToString) else {
            return
        }
        await UIApplication.shared.open(mailToUrl)
    }
}
