import Foundation

struct ShareAsVideoResult {

    var videoFilepath: String
    var contentId: String
    var exportMethod: ExportVideoInterface
    
    init() {
        self.videoFilepath = .empty
        self.contentId = .empty
        self.exportMethod = .shareSheet
    }

}
