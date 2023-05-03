//
//  ConnectionManager.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/05/23.
//

import Foundation
import Reachability

internal protocol ConnectionManagerProtocol {

    func hasConnectivity() -> Bool
}

class ConnectionManager: ConnectionManagerProtocol {
    
    static let shared = ConnectionManager()
    private init () {}
    
    func hasConnectivity() -> Bool {
        do {
            let reachability: Reachability = try Reachability()
            let networkStatus = reachability.connection
            
            switch networkStatus {
            case .unavailable:
                return false
            case .wifi, .cellular:
                return true
            }
        }
        catch {
            return false
        }
    }
}
