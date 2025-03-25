import Foundation

internal protocol NetworkRabbitProtocol {
    
    var serverPath: String { get }

    func `get`<T: Codable>(from url: URL) async throws -> T

    func serverIsAvailable() async -> Bool
    func post(shareCountStat: ServerShareCountStat, completionHandler: @escaping (Bool, String) -> Void)
    func post(clientDeviceInfo: ClientDeviceInfo, completionHandler: @escaping (Bool?, NetworkRabbitError?) -> Void)
    func fetchUpdateEvents(from lastDate: String) async throws -> [UpdateEvent]

    func retroStartingVersion() async -> String?
}

class NetworkRabbit: NetworkRabbitProtocol {

    let serverPath: String

    // NetworkRabbit(serverPath: "https://654e-2804-1b3-8640-96df-d0b4-dd5d-6922-bb1b.sa.ngrok.io/api/")
    static let shared = NetworkRabbit(
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

    func displayAskForMoneyView(completion: @escaping (Bool) -> Void) {
        let url = URL(string: serverPath + "v2/current-test-version")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else { return completion(false) }
            guard httpResponse.statusCode == 200 else { return completion(false) }
            if let data = data {
                let versionFromServer = String(data: data, encoding: .utf8)!
                if versionFromServer == Versioneer.appVersion {
                    completion(false)
                } else {
                    completion(true)
                }
            } else if error != nil {
                completion(false)
            }
        }
        
        task.resume()
    }

//    func displayRecurringDonationBanner(completion: @escaping (Bool) -> Void) {
//        let url = URL(string: serverPath + "v3/display-recurring-donation-banner")!
//
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let httpResponse = response as? HTTPURLResponse else { return completion(false) }
//            guard httpResponse.statusCode == 200 else { return completion(false) }
//            if let data = data {
//                let shouldDisplay = String(data: data, encoding: .utf8)!
//                if shouldDisplay == "1" {
//                    completion(true)
//                } else {
//                    completion(false)
//                }
//            } else if error != nil {
//                completion(false)
//            }
//        }
//
//        task.resume()
//    }
    
    // MARK: - POST
    
    func post(shareCountStat: ServerShareCountStat, completionHandler: @escaping (Bool, String) -> Void) {
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
    
    func post(clientDeviceInfo: ClientDeviceInfo, completionHandler: @escaping (Bool?, NetworkRabbitError?) -> Void) {
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

enum NetworkRabbitError: Error, LocalizedError {

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
