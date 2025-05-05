//
//  APIClient.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 08/06/22.
//

import Foundation

internal protocol APIClientProtocol {
    
    var serverPath: String { get }

    func `get`<T: Codable>(from url: URL) async throws -> T
    func getString(from url: URL) async throws -> String?

    func serverIsAvailable() async -> Bool
    func post(shareCountStat: ServerShareCountStat, completionHandler: @escaping (Bool, String) -> Void)
    func post(clientDeviceInfo: ClientDeviceInfo, completionHandler: @escaping (Bool?, APIClientError?) -> Void)
    func fetchUpdateEvents(from lastDate: String) async throws -> [UpdateEvent]

    func displayAskForMoneyView(appVersion: String) async -> Bool
    func getPixDonorNames() async -> [Donor]?

    func post<T: Encodable>(to url: URL, body: T) async throws
}

class APIClient: APIClientProtocol {

    let serverPath: String

    // APIClient(serverPath: "https://654e-2804-1b3-8640-96df-d0b4-dd5d-6922-bb1b.sa.ngrok.io/api/")
    static let shared = APIClient(
        serverPath: APIConfig.apiURL
    )

    init(serverPath: String) {
        self.serverPath = serverPath
    }

    // MARK: - GET

    func serverIsAvailable() async -> Bool {
        let url = URL(string: serverPath + "v2/status-check")!
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            return httpResponse.statusCode == 200
        } catch {
            print("Erro ao verificar conexão com o servidor: \(error)")
            return false
        }
    }

    func displayAskForMoneyView(appVersion: String) async -> Bool {
        let url = URL(string: serverPath + "v2/current-test-version")!
        do {
            guard let versionFromServer = try await getString(from: url) else { return false }
            return versionFromServer != appVersion
        } catch {
            return false
        }
    }

    func getString(from url: URL) async throws -> String? {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let response = response as? HTTPURLResponse else {
            throw APIClientError.responseWasNotAnHTTPURLResponse
        }
        if response.statusCode == 404 {
            throw APIClientError.resourceNotFound
        }
        guard response.statusCode == 200 else {
            throw APIClientError.unexpectedStatusCode
        }
        return String(data: data, encoding: .utf8)
    }

    func getPixDonorNames() async -> [Donor]? {
        let url = URL(string: serverPath + "v3/donor-names")!

        do {
            return try await get(from: url)
        } catch {
            return nil
        }
    }

    // MARK: - POST
    
    func post(
        shareCountStat: ServerShareCountStat,
        completionHandler: @escaping (Bool, String) -> Void
    ) {
        let url = URL(string: serverPath + "v1/share-count-stat")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(shareCountStat)
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
             
            guard httpResponse.statusCode == 200 else {
                return completionHandler(false, "Failed")
            }
            
            if let data = data {
                if let stat = try? JSONDecoder().decode(ServerShareCountStat.self, from: data) {
                    completionHandler(true, stat.contentId)
                } else {
                    completionHandler(false, "Failed: Invalid Response")
                }
            } else if let error = error {
                completionHandler(false, "HTTP Request Failed \(error.localizedDescription)")
            }
        }

        task.resume()
    }
    
    func post(clientDeviceInfo: ClientDeviceInfo, completionHandler: @escaping (Bool?, APIClientError?) -> Void) {
        let url = URL(string: serverPath + "v1/client-device-info")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(clientDeviceInfo)
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                return completionHandler(nil, .responseWasNotAnHTTPURLResponse)
            }
             
            guard httpResponse.statusCode == 200 else {
                return completionHandler(nil, .unexpectedStatusCode)
            }
            
            if let data = data {
                if (try? JSONDecoder().decode(ClientDeviceInfo.self, from: data)) != nil {
                    completionHandler(true, nil)
                } else {
                    completionHandler(nil, .invalidResponse)
                }
            } else if error != nil {
                completionHandler(nil, .httpRequestFailed)
            }
        }

        task.resume()
    }
}

enum APIClientError: Error, LocalizedError {

    case unexpectedStatusCode
    case responseWasNotAnHTTPURLResponse
    case invalidResponse
    case httpRequestFailed
    case errorFetchingUpdateEvents(String)
    case resourceNotFound

    var errorDescription: String? {
        switch self {
        case .unexpectedStatusCode:
            return "O servidor respondeu com um código de status inesperado."
        case .responseWasNotAnHTTPURLResponse:
            return "A resposta da rede não foi uma resposta HTTP URL."
        case .invalidResponse:
            return "A resposta do servidor é inválida ou está corrompida."
        case .httpRequestFailed:
            return "A requisição HTTP falhou devido a um erro de rede ou servidor."
        case .errorFetchingUpdateEvents(let errorMessage):
            return "Erro ao obter UpdateEvents: \(errorMessage)"
        case .resourceNotFound:
            return "Recurso não encontrado."
        }
    }
}
