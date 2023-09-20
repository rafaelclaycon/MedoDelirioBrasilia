//
//  NetworkMonitor.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 15/08/23.
//

import SwiftUI
import Reachability

class NetworkMonitor: ObservableObject {

    private let reachability = try! Reachability()

    @Published var isConnected: Bool = true

    init() {
        setupReachability()
    }

    private func setupReachability() {
        reachability.whenReachable = { reachability in
            DispatchQueue.main.async { [weak self] in
                self?.isConnected = true
            }
        }
        reachability.whenUnreachable = { reachability in
            DispatchQueue.main.async { [weak self] in
                self?.isConnected = false
            }
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Failed to start network monitor")
        }
    }
}
