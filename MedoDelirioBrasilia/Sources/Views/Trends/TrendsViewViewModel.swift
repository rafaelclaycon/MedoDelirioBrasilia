//
//  TrendsViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 30/05/22.
//

import Combine
import SwiftUI

class TrendsViewViewModel: ObservableObject {

    @Published var personalTop5: [TopChartItem]? = nil
    @Published var audienceTop5: [TopChartItem]? = nil

    // Toast
    @Published var showToastView: Bool = false
    @Published var toastIcon: String = "checkmark"
    @Published var toastIconColor: Color = .green
    @Published var toastText: String = ""

    func reloadPersonalList(withTopChartItems topChartItems: [TopChartItem]?) {
        self.personalTop5 = topChartItems
    }
    
    func reloadAudienceList() {
        var topCharts = [TopChartItem]()
        
        topCharts.append(TopChartItem(id: UUID().uuidString, rankNumber: "1", contentId: "", contentName: "Teste", contentAuthorId: "", contentAuthorName: "Autor", shareCount: 10))
        
        DispatchQueue.main.async {
            self.audienceTop5 = topCharts
        }
    }

    // MARK: - Toast

    func displayToast(
        _ toastIcon: String = "checkmark",
        _ toastIconColor: Color = .green,
        toastText: String,
        displayTime: DispatchTimeInterval = .seconds(3),
        completion: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
            withAnimation {
                self.toastIcon = toastIcon
                self.toastIconColor = toastIconColor
                self.toastText = toastText
                self.showToastView = true
            }
            TapticFeedback.success()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + displayTime) {
            withAnimation {
                self.showToastView = false
                completion?()
            }
        }
    }
}
