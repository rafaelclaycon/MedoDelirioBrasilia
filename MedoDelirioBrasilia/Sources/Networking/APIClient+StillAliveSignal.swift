//
//  APIClient+StillAliveSignal.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/10/22.
//

import Foundation

extension APIClient {

    func post(signal: StillAliveSignal, completion: @escaping (Bool?, APIClientError?) -> Void) {
        let url = URL(string: serverPath + "v1/still-alive-signal")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(signal)
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(nil, .responseWasNotAnHTTPURLResponse)
            }
            guard httpResponse.statusCode == 200 else {
                return completion(nil, .unexpectedStatusCode)
            }
            guard error == nil else {
                return completion(nil, .httpRequestFailed)
            }
            completion(true, nil)
        }

        task.resume()
    }
}
