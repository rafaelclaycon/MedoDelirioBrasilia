//
//  NetworkRabbit+Files.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 27/04/23.
//

import Foundation

extension NetworkRabbit {
    
    static func downloadFile(from url: URL, into subfolder: String) async throws -> String {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsUrl.absoluteString)
        let destinationUrl = documentsUrl.appendingPathComponent(subfolder + url.lastPathComponent)
        print(destinationUrl)
        
        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("File already exists [\(destinationUrl.path)]")
            return destinationUrl.path
        } else {
            let session = URLSession(configuration: URLSessionConfiguration.default)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw FileError.unableToParseResponse
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                print("downloadFile() - Response: \(httpResponse.statusCode)")
                throw FileError.downloadFailed
            }
            try data.write(to: destinationUrl, options: .atomic)
            return destinationUrl.path
        }
    }
}

enum FileError: Error {
    
    case fileExists, downloadFailed, unableToParseResponse
}
