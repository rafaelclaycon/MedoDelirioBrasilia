//
//  ConnectionManagerStub.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 03/05/23.
//

import Foundation

@testable import MedoDelirio
import Foundation

class ConnectionManagerStub: ConnectionManagerProtocol {

    var hasConnectivityResult = true
    
    func hasConnectivity() -> Bool {
        return hasConnectivityResult
    }
}
