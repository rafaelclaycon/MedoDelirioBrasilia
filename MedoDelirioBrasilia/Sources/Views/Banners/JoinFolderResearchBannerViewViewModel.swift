//
//  JoinFolderResearchBannerViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 24/10/22.
//

import Combine
import UIKit

class JoinFolderResearchBannerViewViewModel: ObservableObject {

    @Published var state: JoinFolderResearchBannerViewState
    
    init(state: JoinFolderResearchBannerViewState) {
        self.state = state
    }
    
    func sendLogs() {
        DispatchQueue.main.async {
            self.state = .sendingInfo
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                return
            }
            
            var hadErrorsSending = false
            
            guard let folders = try? database.getAllUserFolders(), !folders.isEmpty else {
                return
            }
            
            var folderLogs = [UserFolderLog]()
            
            folders.forEach { folder in
                folderLogs.append(UserFolderLog(installId: UIDevice.identifiderForVendor,
                                                folderId: folder.id,
                                                folderSymbol: folder.symbol,
                                                folderName: folder.name,
                                                backgroundColor: folder.backgroundColor,
                                                logDateTime: Date.now.iso8601withFractionalSeconds))
            }
            
            folderLogs.forEach { folderLog in
                networkRabbit.post(folderLog: folderLog) { success, error in
                    guard let success = success, success else {
                        // TODO: Mark for resend
                        hadErrorsSending = true
                        return
                    }
                    if let contentIds = try? database.getAllSoundIdsInsideUserFolder(withId: folderLog.folderId) {
                        guard !contentIds.isEmpty else {
                            return
                        }
                        contentIds.forEach { folderContentId in
                            let contentLog = UserFolderContentLog(userFolderLogId: folderLog.id, contentId: folderContentId)
                            
                            networkRabbit.post(folderContentLog: contentLog) { success, error in
                                guard let success = success, success else {
                                    // TODO: Mark for resend
                                    hadErrorsSending = true
                                    return
                                }
                            }
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.state = hadErrorsSending ? .errorSending : .doneSending
            }
        }
    }

}
