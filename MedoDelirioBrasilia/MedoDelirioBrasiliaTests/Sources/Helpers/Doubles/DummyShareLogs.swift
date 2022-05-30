@testable import MedoDelirioBrasilia
import Foundation

class DummyShareLogs {

    private static let installId = "76BE9811-D3D6-4DFC-8B37-6A8B83A1DF9A"
    
    private static let firstContentId = "1432E4A4-2D05-4439-936E-143E4B7E89B3"
    
    static func getShitloadOfSoundShareLogs() -> [ShareLog] {
        var result = [ShareLog]()
        result.append(ShareLog(installId: installId, contentId: firstContentId, contentType: 0, dateTime: Date(), destination: 0, destinationBundleId: ""))
        result.append(ShareLog(installId: installId, contentId: firstContentId, contentType: 0, dateTime: Date(), destination: 0, destinationBundleId: ""))
        result.append(ShareLog(installId: installId, contentId: firstContentId, contentType: 0, dateTime: Date(), destination: 0, destinationBundleId: ""))
        result.append(ShareLog(installId: installId, contentId: firstContentId, contentType: 0, dateTime: Date(), destination: 0, destinationBundleId: ""))
        result.append(ShareLog(installId: installId, contentId: firstContentId, contentType: 0, dateTime: Date(), destination: 0, destinationBundleId: ""))
        result.append(ShareLog(installId: installId, contentId: firstContentId, contentType: 0, dateTime: Date(), destination: 0, destinationBundleId: ""))
        result.append(ShareLog(installId: installId, contentId: firstContentId, contentType: 0, dateTime: Date(), destination: 0, destinationBundleId: ""))
        result.append(ShareLog(installId: installId, contentId: firstContentId, contentType: 0, dateTime: Date(), destination: 0, destinationBundleId: ""))
        result.append(ShareLog(installId: installId, contentId: firstContentId, contentType: 0, dateTime: Date(), destination: 0, destinationBundleId: ""))
        result.append(ShareLog(installId: installId, contentId: firstContentId, contentType: 0, dateTime: Date(), destination: 0, destinationBundleId: ""))
        return result
    }

}
