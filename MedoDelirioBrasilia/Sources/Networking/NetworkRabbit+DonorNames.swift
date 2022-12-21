//
//  NetworkRabbit+DonorNames.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 21/12/22.
//

import Foundation

extension NetworkRabbit {

    func getPixDonorNames(completionHandler: @escaping (String) -> Void) {
        let url = URL(string: serverPath + "v2/donor-names")!
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                let response = String(data: data, encoding: .utf8)!
                completionHandler(response)
            } else if error != nil {
                completionHandler(.empty)
            }
        }
        
        task.resume()
    }

}
