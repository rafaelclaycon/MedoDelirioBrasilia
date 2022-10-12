import Combine
import SwiftUI

class DiagnosticsViewViewModel: ObservableObject {

    func sendShareCountStats() {
        podium.exchangeShareCountStatsWithTheServer(timeInterval: .allTime) { result, _ in
            guard result == .successful || result == .noStatsToSend else {
                return
            }
            print(result)
        }
    }

}
