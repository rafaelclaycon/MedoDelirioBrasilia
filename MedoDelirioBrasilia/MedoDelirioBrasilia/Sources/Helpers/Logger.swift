import UIKit

class Logger {

    static func logSharedSound(contentId: String, destination: ShareDestination, destinationBundleId: String) {
        let shareLog = ShareLog(installId: UIDevice.current.identifierForVendor?.uuidString ?? "",
                                contentId: contentId,
                                contentType: 0,
                                dateTime: Date(),
                                destination: destination.rawValue,
                                destinationBundleId: destinationBundleId)
        try? database.insert(shareLog: shareLog)
    }
    
    static func getTop5Sounds() -> [TopChartItem]? {
        var result = [TopChartItem]()
        var filteredSounds: [Sound]
        var filteredAuthors: [Author]
        var itemInPreparation: TopChartItem
        
        guard let dimItems = try? database.getTop5SharedContent(), dimItems.count > 0 else {
            return nil
        }
        
        for i in 0...(dimItems.count - 1) {
            filteredSounds = soundData.filter({ $0.id == dimItems[i].contentId })
            
            guard filteredSounds.count > 0 else {
                continue
            }
            
            filteredAuthors = authorData.filter({ $0.id == filteredSounds[0].authorId })
            
            guard filteredAuthors.count > 0 else {
                continue
            }
            
            itemInPreparation = TopChartItem(id: "\(i + 1)", contentId: dimItems[i].contentId, contentName: filteredSounds[0].title, contentAuthorId: filteredSounds[0].authorId, contentAuthorName: filteredAuthors[0].name, shareCount: dimItems[i].shareCount)
            
            result.append(itemInPreparation)
        }
        
        if result.count > 0 {
            return result
        } else {
            return nil
        }
    }

}
