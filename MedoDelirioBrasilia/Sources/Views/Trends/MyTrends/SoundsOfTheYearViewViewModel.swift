//
//  SoundsOfTheYearViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 10/10/23.
//

import Combine

class SoundsOfTheYearViewViewModel: ObservableObject {

    @Published var topFive: [TopChartItem] = []
    @Published var selectedSocialNetwork = IntendedVideoDestination.twitter.rawValue
    @Published var isShowingProcessingView = false

    // Alerts
    @Published var alertTitle: String = .empty
    @Published var alertMessage: String = .empty
    @Published var showAlert: Bool = false

    func retrieveTopFive() {
        do {
            let sounds = try LocalDatabase.shared.sounds(
                allowSensitive: true,
                favoritesOnly: false
            )
            for i in 1...5 {
                topFive.append(
                    .init(
                        rankNumber: "\(i)",
                        contentName: sounds.randomElement()!.title
                    )
                )
            }
        } catch {
            print("Deu ruim")
        }
    }
}
