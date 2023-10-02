//
//  SharingUtility.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import UIKit

class SharingUtility {

    static func shareSound(
        from url: URL,
        andContentId contentId: String,
        completionHandler: @escaping (Bool) -> Void
    ) throws {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
        activityVC.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
                guard let activity = activity else {
                    return
                }
                let destination = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
                Logger.shared.logSharedSound(contentId: contentId, destination: destination, destinationBundleId: activity.rawValue)
                
                AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()
                
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
    
    static func share(sounds: [Sound], completionHandler: @escaping (Bool) -> Void) throws {
        guard sounds.isEmpty == false else {
            return
        }
        
        var urls = [URL]()
        
        try sounds.forEach { sound in
            urls.append(try sound.fileURL())
        }
        
        // let wppURL = URL(string: "whatsapp://app")!

//        if UIApplication.shared.canOpenURL(wppURL) {
//            var filePaths = ""
//            for url in urls {
//                filePaths += "\(url.absoluteString),"
//            }
//            let urlEncodedFilePaths = filePaths.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
//            let wppURLWithFilePaths = URL(string: "whatsapp://send?file=\(urlEncodedFilePaths)")!
//            UIApplication.shared.open(wppURLWithFilePaths)
//        } else {
            let activityVC = UIActivityViewController(activityItems: urls, applicationActivities: nil)
            DispatchQueue.main.async {
                UIApplication.shared.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
            }
            activityVC.completionWithItemsHandler = { activity, completed, items, error in
                if completed {
                    guard let activity = activity else {
                        return
                    }
                    _ = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
    //                Logger.logSharedSound(contentId: contentId, destination: destination, destinationBundleId: activity.rawValue)
                    
                    AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()
                    
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
    }
    
    static func shareVideoFromSound(withPath filepath: String, andContentId contentId: String, shareSheetDelayInSeconds: Double, completionHandler: @escaping (Bool) -> Void) throws {
        guard filepath.isEmpty == false else {
            return
        }
        
        let url = URL(fileURLWithPath: filepath)
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + shareSheetDelayInSeconds) {
            UIApplication.shared.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
        
        activityVC.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
                guard let activity = activity else {
                    return
                }
                let destination = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
                Logger.shared.logSharedVideoFromSound(contentId: contentId, destination: destination, destinationBundleId: activity.rawValue)
                
                AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()
                
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
    }
    
    static func shareFile(withPath filepath: String) throws {
        guard filepath.isEmpty == false else {
            return
        }
        
        let url = URL(fileURLWithPath: filepath)
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }
}

enum SharerError: Error {

    case unableToFindSoundFile
}
