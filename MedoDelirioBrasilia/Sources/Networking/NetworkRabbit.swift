import Foundation

internal protocol NetworkRabbitProtocol {
    
    var serverPath: String { get }
    
    func checkServerStatus(completionHandler: @escaping (Bool) -> Void)
    func getSoundShareCountStats(timeInterval: TrendsTimeInterval, completionHandler: @escaping ([ServerShareCountStat]?, NetworkRabbitError?) -> Void)
    func post(shareCountStat: ServerShareCountStat, completionHandler: @escaping (Bool, String) -> Void)
    func post(clientDeviceInfo: ClientDeviceInfo, completionHandler: @escaping (Bool?, NetworkRabbitError?) -> Void)
    func post(bundleIdLog: ServerShareBundleIdLog, completionHandler: @escaping (Bool, String) -> Void)
    func fetchUpdateEvents(from lastDate: String) async throws -> [UpdateEvent]
}

class NetworkRabbit: NetworkRabbitProtocol {

    let serverPath: String

    init(serverPath: String) {
        self.serverPath = serverPath
    }

    // MARK: - GET
    
    func checkServerStatus(completionHandler: @escaping (Bool) -> Void) {
        let url = URL(string: serverPath + "v2/status-check")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                return completionHandler(false)
            }
            guard httpResponse.statusCode == 200 else {
                return completionHandler(false)
            }
            completionHandler(true)
        }
        
        task.resume()
    }
    
    func getSoundShareCountStats(timeInterval: TrendsTimeInterval, completionHandler: @escaping ([ServerShareCountStat]?, NetworkRabbitError?) -> Void) {
        var url: URL
        
        switch timeInterval {
        case .last24Hours:
            let refDate: String = Date.dateAsString(addingDays: -1)
            url = URL(string: serverPath + "v2/sound-share-count-stats-from/\(refDate)")!
            
        case .lastWeek:
            let refDate: String = Date.dateAsString(addingDays: -7)
            url = URL(string: serverPath + "v2/sound-share-count-stats-from/\(refDate)")!
        
        case .lastMonth:
            let refDate: String = Date.dateAsString(addingDays: -30)
            url = URL(string: serverPath + "v2/sound-share-count-stats-from/\(refDate)")!
        
        case .allTime:
            url = URL(string: serverPath + "v2/sound-share-count-stats-all-time")!
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                return completionHandler(nil, .responseWasNotAnHTTPURLResponse)
            }
             
            guard httpResponse.statusCode == 200 else {
                return completionHandler(nil, .unexpectedStatusCode)
            }
            
            if let data = data {
                if let stats = try? JSONDecoder().decode([ServerShareCountStat].self, from: data) {
                    Logger.shared.logNetworkCall(callType: NetworkCallType.getSoundShareCountStats.rawValue, requestUrl: url.absoluteString, requestBody: nil, response: String(data: data, encoding: .utf8)!, wasSuccessful: true)
                    completionHandler(stats, nil)
                } else {
                    completionHandler(nil, .invalidResponse)
                }
            } else if error != nil {
                completionHandler(nil, .httpRequestFailed)
            }
        }

        task.resume()
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

    func displayRecurringDonationBanner(completion: @escaping (Bool) -> Void) {
        let url = URL(string: serverPath + "v3/display-recurring-donation-banner")!

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else { return completion(false) }
            guard httpResponse.statusCode == 200 else { return completion(false) }
            if let data = data {
                let shouldDisplay = String(data: data, encoding: .utf8)!
                if shouldDisplay == "1" {
                    completion(true)
                } else {
                    completion(false)
                }
            } else if error != nil {
                completion(false)
            }
        }

        task.resume()
    }
    
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
    
    func post(bundleIdLog: ServerShareBundleIdLog, completionHandler: @escaping (Bool, String) -> Void) {
        let url = URL(string: serverPath + "v1/shared-to-bundle-id")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(bundleIdLog)
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
             
            guard httpResponse.statusCode == 200 else {
                return completionHandler(false, "Failed")
            }
            
            if let data = data {
                if let log = try? JSONDecoder().decode(ServerShareBundleIdLog.self, from: data) {
                    completionHandler(true, log.bundleId)
                } else {
                    completionHandler(false, "Failed: Invalid Response")
                }
            } else if let error = error {
                completionHandler(false, "HTTP Request Failed \(error.localizedDescription)")
            }
        }

        task.resume()
    }

}

enum NetworkRabbitError: Error {

    case unexpectedStatusCode
    case responseWasNotAnHTTPURLResponse
    case invalidResponse
    case httpRequestFailed
    case errorFetchingUpdateEvents(String)
}
