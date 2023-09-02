//
//  Bundle+.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/04/23.
//

import Foundation

extension Bundle {

    func decodeJSON<T: Decodable>(_ filename: String) throws -> T {
        let data: Data

        guard let file = self.url(forResource: filename, withExtension: nil)
        else {
            throw JSONDecodeError.fileNotFound(filename: filename)
        }

        do {
            data = try Data(contentsOf: file)
        } catch {
            throw JSONDecodeError.unableToLoad(filename: filename)
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw JSONDecodeError.parseError(filename: filename)
        }
    }

    enum JSONDecodeError: LocalizedError {

        case fileNotFound(filename: String)
        case unableToLoad(filename: String)
        case parseError(filename: String)

        var errorDescription: String? {
            switch self {
            case .fileNotFound(let filename):
                return NSLocalizedString("Não foi possível encontrar \(filename) no main bundle.", comment: "")
            case .unableToLoad(let filename):
                return NSLocalizedString("Não foi possível carregar \(filename) do main bundle.", comment: "")
            case .parseError(let filename):
                return NSLocalizedString("Não foi possível interpretar o arquivo \(filename) como o tipo passado.", comment: "")
            }
        }
    }
}
