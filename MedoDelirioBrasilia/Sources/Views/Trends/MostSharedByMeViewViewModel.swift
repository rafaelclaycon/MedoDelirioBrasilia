//
//  MostSharedByMeViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 11/10/22.
//

import Combine

class MostSharedByMeViewViewModel: ObservableObject {

    @Published var personalTop5: [TopChartItem]? = nil
    
    func reloadPersonalList(withTopChartItems topChartItems: [TopChartItem]?) {
        self.personalTop5 = topChartItems
    }

}
