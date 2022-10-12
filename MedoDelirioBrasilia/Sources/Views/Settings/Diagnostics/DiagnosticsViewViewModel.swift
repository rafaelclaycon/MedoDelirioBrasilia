import Combine
import SwiftUI

class DiagnosticsViewViewModel: ObservableObject {

    func sendShareCountStats() {
        podium.exchangeShareCountStatsWithTheServer { result, _ in
            guard result == .successful || result == .noStatsToSend else {
                return
            }
            print(result)
        }
    }

}
