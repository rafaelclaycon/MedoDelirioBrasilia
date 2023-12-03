//
//  MostSharedByMeViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 11/10/22.
//

import Foundation
import Combine

class MostSharedByMeViewViewModel: ObservableObject {

    @Published var personalTop10: [TopChartItem]? = nil

    @Published var viewState: TrendsViewState = .noDataToDisplay

    func reloadPersonalList() {
        Task { @MainActor in
            self.personalTop10 = Podium.shared.getTop10SoundsSharedByTheUser()
        }
    }
}
