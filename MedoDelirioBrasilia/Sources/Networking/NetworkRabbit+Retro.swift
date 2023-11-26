//
//  NetworkRabbit+Retro.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 25/11/23.
//

import Foundation

extension NetworkRabbit {

    func retroStartingVersion() async -> String? {
        let url = URL(string: serverPath + "v3/retro-starting-version")!
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else { return nil }
            guard httpResponse.statusCode == 200 else { return nil }
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
