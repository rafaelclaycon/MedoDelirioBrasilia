//
//  TrendsViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 30/05/22.
//

import Combine
import SwiftUI

extension TrendsView {

    final class ViewModel: ObservableObject {

        // Toast
        @Published var showToastView: Bool = false
        @Published var toastIcon: String = "checkmark"
        @Published var toastIconColor: Color = .green
        @Published var toastText: String = ""

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
}
