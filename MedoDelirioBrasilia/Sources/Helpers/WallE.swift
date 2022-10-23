//
//  WallE.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 20/10/22.
//

import Foundation

class WallE {

    static func deleteAllVideoFilesFromDocumentsDir() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            fileURLs.forEach { fileURL in
                if fileURL.absoluteString.contains(".mov") {
                    try? FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }

}
