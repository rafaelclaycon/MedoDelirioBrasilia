//
//  APIConfig.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 21/09/24.
//

import Foundation

final class APIConfig {

    static var baseServerURL: String {
        switch ProcessInfo.processInfo.environment["api_environment"] {
        case "local":
            return "http://127.0.0.1:8080/"
        case "dev":
            return "http://medodelirioios.xyz:8080/"
        default:
            return "http://medodelirioios.com:8080/"
        }
    }

    static var apiURL: String {
        self.baseServerURL + "api/"
    }
}
