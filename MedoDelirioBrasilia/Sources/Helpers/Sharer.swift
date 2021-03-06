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
    }

}

enum SharerError: Error {

    case unableToFindSoundFile

}
