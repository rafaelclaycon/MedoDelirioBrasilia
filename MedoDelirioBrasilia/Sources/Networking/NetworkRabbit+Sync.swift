//
//  NetworkRabbit+Sync.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/05/23.
//

import Foundation

extension NetworkRabbit {
    
    func fetchUpdateEvents() async throws -> [UpdateEvent] {
        let url = URL(string: serverPath + "v3/update-events/\(Date.now.iso8601withFractionalSeconds)")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse else {
            throw NetworkRabbitError.responseWasNotAnHTTPURLResponse
        }
        guard response.statusCode == 200 else {
            print(response.statusCode)
            throw NetworkRabbitError.unexpectedStatusCode
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode([UpdateEvent].self, from: data)
    }
}
