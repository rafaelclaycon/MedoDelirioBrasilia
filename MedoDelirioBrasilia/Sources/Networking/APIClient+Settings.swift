//
//  APIClient+Settings.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 08/05/25.
//

import Foundation

extension APIClient {

    func displayAskForMoneyView(appVersion: String) async -> Bool {
        let url = URL(string: serverPath + "v2/current-test-version")!
        do {
            guard let versionFromServer = try await getString(from: url) else { return false }
            return versionFromServer != appVersion
        } catch {
            return false
        }
    }

    func getDonorNames() async -> [Donor]? {
        let url = URL(string: serverPath + "v3/donor-names")!

        do {
            return try await get(from: url)
        } catch {
            return nil
        }
    }

    func moneyInfo() async throws -> [MoneyInfo] {
        let url = URL(string: serverPath + "v4/money-info")!
        let dtos: [MoneyInfoDTO] = try await get(from: url)
        return dtos.map { dto in
            MoneyInfo(
                title: dto.title,
                subtitle: dto.subtitle,
                currentValue: dto.currentValue,
                totalValue: dto.totalValue,
                barColor: dto.barColor.toColor()
            )
        }
    }
}
