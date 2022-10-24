//
//  NetworkRabbit+UserFolderLog.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 24/10/22.
//

import Foundation

extension NetworkRabbit {

    func post(folderLog: UserFolderLog, completion: @escaping (Bool?, NetworkRabbitError?) -> Void) {
        let url = URL(string: serverPath + "v1/user-folder-log")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(folderLog)
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(nil, .responseWasNotAnHTTPURLResponse)
            }
             
            guard httpResponse.statusCode == 200 else {
                return completion(nil, .unexpectedStatusCode)
            }
            
            if let data = data {
                if (try? JSONDecoder().decode(UserFolderLog.self, from: data)) != nil {
                    completion(true, nil)
                } else {
                    completion(nil, .invalidResponse)
                }
            } else if error != nil {
                completion(nil, .httpRequestFailed)
            }
        }
        
        task.resume()
    }
    
    func post(folderContentLog: UserFolderContentLog, completion: @escaping (Bool?, NetworkRabbitError?) -> Void) {
        let url = URL(string: serverPath + "v1/user-folder-content-log")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(folderContentLog)
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(nil, .responseWasNotAnHTTPURLResponse)
            }
             
            guard httpResponse.statusCode == 200 else {
                return completion(nil, .unexpectedStatusCode)
            }
            
            if let data = data {
                if (try? JSONDecoder().decode(UserFolderContentLog.self, from: data)) != nil {
                    completion(true, nil)
                } else {
                    completion(nil, .invalidResponse)
                }
            } else if error != nil {
                completion(nil, .httpRequestFailed)
            }
        }
        
        task.resume()
    }

}
