import Combine
import SwiftUI

class DiagnosticsViewViewModel: ObservableObject {

    func exportDatabase() {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            return
        }
        
        let originPath = LocalDatabase.databaseFilepath()
        var destinationPath = ""
        
        // Copy
        do {
            let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory())
            destinationPath = tempDirURL.path + "/medo_db.sqlite3"
            
            if FileManager.default.fileExists(atPath: destinationPath) {
                try FileManager.default.removeItem(atPath: destinationPath)
            }
            try FileManager.default.copyItem(atPath: originPath, toPath: destinationPath)
        } catch (let error) {
            print("Cannot copy item at \(originPath) to \(destinationPath): \(error)")
            return
        }
        
        // Show Share Sheet
        if UIDevice.current.userInterfaceIdiom == .phone {
            do {
                try Sharer.shareFile(withPath: destinationPath)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

}
