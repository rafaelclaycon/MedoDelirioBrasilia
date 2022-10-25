//
//  NetworkRabbit+UserFolderLog.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 24/10/22.
//

import Foundation

extension NetworkRabbit {

    func post(folderLogs: [UserFolderLog], completion: @escaping (Bool?, NetworkRabbitError?) -> Void) {
        let url = URL(string: serverPath + "v1/user-folder-logs")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(folderLogs)
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
    
    func post(folderContentLogs: [UserFolderContentLog], completion: @escaping (Bool?, NetworkRabbitError?) -> Void) {
        let url = URL(string: serverPath + "v1/user-folder-content-logs")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(folderContentLogs)
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
