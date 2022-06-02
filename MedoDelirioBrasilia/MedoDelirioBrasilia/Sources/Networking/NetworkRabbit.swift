import UIKit

class NetworkRabbit {

    static func getHelloFromServer(completionHandler: @escaping (String) -> Void) {
        let url = URL(string: "http://170.187.145.233:8080/hello/MedoDelirioBrasilia")!

        //var request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                completionHandler(String(data: data, encoding: .utf8)!)
            } else if let error = error {
                completionHandler("HTTP Request Failed \(error.localizedDescription)")
            }
        }

        task.resume()
    }

}
