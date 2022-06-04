import UIKit

class NetworkRabbit {

    private let serverPath: String
    
    init(serverPath: String) {
        self.serverPath = serverPath
    }
    
    // MARK: - GET
    
    func getHelloFromServer(completionHandler: @escaping (String) -> Void) {
        let url = URL(string: "\(serverPath)/hello/MedoDelirioBrasilia")!

        //var request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            /*guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
             
            httpResponse.statusCode*/
            
            if let data = data {
                completionHandler(String(data: data, encoding: .utf8)!)
            } else if let error = error {
                completionHandler("HTTP Request Failed \(error.localizedDescription)")
            }
        }

        task.resume()
    }
    
    func checkServerStatus(completionHandler: @escaping (String) -> Void) {
        let url = URL(string: serverPath)!

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                completionHandler(String(data: data, encoding: .utf8)!)
            } else if let error = error {
                completionHandler("A requisição HTTP falhou: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
    
    func getSoundShareCountStats(completionHandler: @escaping ([ServerShareCountStat]?, NetworkRabbitError?) -> Void) {
        let url = URL(string: "\(serverPath)/api/SoundShareCountStats")!

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                return completionHandler(nil, .responseWasNotAnHTTPURLResponse)
            }
             
            guard httpResponse.statusCode == 200 else {
                return completionHandler(nil, .unexpectedStatusCode)
            }
            
            if let data = data {
                if let stats = try? JSONDecoder().decode([ServerShareCountStat].self, from: data) {
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
    
    // MARK: - POST
    
    func post(shareCountStat: ServerShareCountStat, completionHandler: @escaping (String) -> Void) {
        let url = URL(string: "\(serverPath)/api/ShareCountStat")!

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
                return completionHandler("Failed")
            }
            
            if let data = data {
                if let stat = try? JSONDecoder().decode(ServerShareCountStat.self, from: data) {
                    completionHandler(stat.contentId)
                } else {
                    completionHandler("Failed: Invalid Response")
                }
            } else if let error = error {
                completionHandler("HTTP Request Failed \(error.localizedDescription)")
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

}
