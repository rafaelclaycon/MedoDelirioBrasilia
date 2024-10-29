//
//  JoinFolderResearchBannerView+ViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 24/10/22.
//

import Foundation
import Combine

extension JoinFolderResearchBannerView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var state: JoinFolderResearchBannerViewState

        init(state: JoinFolderResearchBannerViewState) {
            self.state = state
        }

        func sendLogs() async {
            state = .sendingInfo

            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }

                FolderResearchHelper.sendLogs { success in
                    DispatchQueue.main.async {
                        if success {
                            AppPersistentMemory.setHasJoinedFolderResearch(to: true)
                            AppPersistentMemory.setHasSentFolderResearchInfo(to: true)
                            self.state = .doneSending
                        } else {
                            self.state = .errorSending
                        }
                    }
                }
            }
        }

    }
}
