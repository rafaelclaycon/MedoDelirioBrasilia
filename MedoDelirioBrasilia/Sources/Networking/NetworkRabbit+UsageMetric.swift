//
//  NetworkRabbit+UsageMetric.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 11/12/22.
//

import Foundation

extension NetworkRabbit {

    func post(usageMetric: UsageMetric) {
        let url = URL(string: serverPath + "v2/usage-metric")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(usageMetric)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { _, _, _ in
            // Do nothing
        }
        
        task.resume()
    }

}
