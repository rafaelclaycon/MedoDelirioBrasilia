import Foundation

extension NetworkRabbit {

    func post(pushDevice: PushDevice, completionHandler: @escaping (Bool?, NetworkRabbitError?) -> Void) {
        let url = URL(string: serverPath + "v1/push-device")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(pushDevice)
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                return completionHandler(nil, .responseWasNotAnHTTPURLResponse)
            }
             
            guard httpResponse.statusCode == 200 else {
                return completionHandler(nil, .unexpectedStatusCode)
            }
            
            if let data = data {
                if (try? JSONDecoder().decode(PushDevice.self, from: data)) != nil {
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
