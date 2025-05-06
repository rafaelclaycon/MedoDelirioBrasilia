//
//  BannerRepository.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 30/04/25.
//

import Foundation

protocol BannerRepositoryProtocol {

    func dynamicBanner() async -> DynamicBannerData?
}

final class BannerRepository: BannerRepositoryProtocol {

    private let apiClient: APIClientProtocol
    private let currentAppVersion: String

    // MARK: - Initializer

    init(
        apiClient: APIClientProtocol = APIClient(serverPath: APIConfig.apiURL),
        currentAppVersion: String = Versioneer.appVersion
    ) {
        self.apiClient = apiClient
        self.currentAppVersion = currentAppVersion
    }

    func dynamicBanner() async -> DynamicBannerData? {
        do {
            let url = URL(string: apiClient.serverPath + "v4/dynamic-banner-dont-show-version")!
            guard let blockedVersion = try await apiClient.getString(from: url) else {
                return nil
            }
            guard currentAppVersion != blockedVersion else { return nil }
            let dataUrl = URL(string: apiClient.serverPath + "v4/dynamic-banner")!
            return try await apiClient.get(from: dataUrl)
        } catch {
            print("Unable to check or populate the Dynamic Banner: \(error.localizedDescription)")
            return nil
        }
    }
}
