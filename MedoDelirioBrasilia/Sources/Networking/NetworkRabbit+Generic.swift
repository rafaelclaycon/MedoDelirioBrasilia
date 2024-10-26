//
//  NetworkRabbit+Generic.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 04/05/23.
//

import Foundation

extension NetworkRabbit {
    
    func `get`<T: Codable>(from url: URL) async throws -> T {
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

    func post<T: Codable, U: Encodable>(to url: URL, body: U) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkRabbitError.responseWasNotAnHTTPURLResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkRabbitError.unexpectedStatusCode
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(T.self, from: data)
    }
}
