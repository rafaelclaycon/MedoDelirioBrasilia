//
//  FolderResearchHelper.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 25/10/22.
//

import UIKit

class FolderResearchHelper {

    static func sendLogs(completion: @escaping (Bool) -> Void) {
        guard let folders = try? LocalDatabase.shared.getAllUserFolders(), !folders.isEmpty else {
            return completion(false)
        }
        
        var folderLogs = [UserFolderLog]()
        var folderContentLogs = [UserFolderContentLog]()
        
        folders.forEach { folder in
            folderLogs.append(UserFolderLog(installId: UIDevice.customInstallId,
                                            folderId: folder.id,
                                            folderSymbol: folder.symbol,
                                            folderName: folder.name,
                                            backgroundColor: folder.backgroundColor,
                                            logDateTime: Date.now.iso8601withFractionalSeconds))
        }
        
        NetworkRabbit.shared.post(folderLogs: folderLogs) { success, error in
            guard let success = success, success else {
                // TODO: Mark for resend
                //hadErrorsSending = true
                return completion(false)
            }
            
            folderLogs.forEach { folderLog in
                if let contentIds = try? LocalDatabase.shared.getAllSoundIdsInsideUserFolder(withId: folderLog.folderId) {
                    guard !contentIds.isEmpty else {
                        return
                    }
                    contentIds.forEach { folderContentId in
                        let contentLog = UserFolderContentLog(userFolderLogId: folderLog.id, contentId: folderContentId)
                        folderContentLogs.append(contentLog)
                    }
                }
            }
            
            NetworkRabbit.shared.post(folderContentLogs: folderContentLogs) { success, error in
                guard let success = success, success else {
                    // TODO: Mark for resend
                    //hadErrorsSending = true
                    return completion(false)
                }
                completion(true)
            }
        }
    }

}
