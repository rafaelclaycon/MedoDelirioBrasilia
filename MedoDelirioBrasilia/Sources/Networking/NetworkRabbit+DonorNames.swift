//
//  NetworkRabbit+DonorNames.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 21/12/22.
//

import Foundation

extension NetworkRabbit {

    func getPixDonorNames(completion: @escaping ([Donor]?) -> Void) {
        let url = URL(string: serverPath + "v3/donor-names")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else { return completion(nil) }
            guard httpResponse.statusCode == 200 else { return completion(nil) }
            if let data = data {
                guard let donors = try? JSONDecoder().decode([Donor].self, from: data) else {
                    return completion(nil)
                }
                completion(donors)
            }
        }
        
        task.resume()
    }

}
