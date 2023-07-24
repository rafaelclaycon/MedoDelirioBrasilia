//
//  NetworkRabbit+Sync.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/05/23.
//

import Foundation

extension NetworkRabbit {
    
    func fetchUpdateEvents(from lastDate: String) async throws -> [UpdateEvent] {
        let url = URL(string: serverPath + "v3/update-events/\(lastDate)")!

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let response = response as? HTTPURLResponse else {
                throw NetworkRabbitError.responseWasNotAnHTTPURLResponse
            }
            guard (200...299).contains(response.statusCode) else {
                print(serverPath + "v3/update-events/\(lastDate) - Response: \(response.statusCode)")
                throw NetworkRabbitError.unexpectedStatusCode
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return try decoder.decode([UpdateEvent].self, from: data)
        } catch {
            throw NetworkRabbitError.errorFetchingUpdateEvents(error.localizedDescription)
        }
    }
}
