//
//  NetworkRabbit+Generic.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 04/05/23.
//

import Foundation

extension NetworkRabbit {
    
    static func `get`<T: Codable>(from url: URL) async throws -> T {
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
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(T.self, from: data)
    }
}
