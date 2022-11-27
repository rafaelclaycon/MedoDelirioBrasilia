import UIKit

class Sharer {

    static func shareSound(withPath filepath: String, andContentId contentId: String, completionHandler: @escaping (Bool) -> Void) throws {
        guard filepath.isEmpty == false else {
            return
        }
        
        guard let path = Bundle.main.path(forResource: filepath, ofType: nil) else {
            throw SharerError.unableToFindSoundFile
        }
        let url = URL(fileURLWithPath: path)
        
        #if os(iOS)
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
                Logger.logSharedSound(contentId: contentId, destination: destination, destinationBundleId: activity.rawValue)
                
                AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()
                
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
        #endif
    }
    
    static func shareVideoFromSound(withPath filepath: String, andContentId contentId: String, shareSheetDelayInSeconds: Double, completionHandler: @escaping (Bool) -> Void) throws {
        guard filepath.isEmpty == false else {
            return
        }
        
        let url = URL(fileURLWithPath: filepath)
        
        #if os(iOS)
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
                Logger.logSharedVideoFromSound(contentId: contentId, destination: destination, destinationBundleId: activity.rawValue)
                
                AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()
                
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
        #endif
    }
    
    static func shareFile(withPath filepath: String) throws {
        guard filepath.isEmpty == false else {
            return
        }
        
        let url = URL(fileURLWithPath: filepath)
        
        #if os(iOS)
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
        #endif
    }

}

enum SharerError: Error {

    case unableToFindSoundFile

}
