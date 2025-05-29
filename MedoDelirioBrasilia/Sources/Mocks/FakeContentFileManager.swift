//
//  FakeContentFileManager.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/05/25.
//

import Foundation

final class FakeContentFileManager: ContentFileManagerProtocol {

    var didCallDownloadSound: Bool = false
    var didCallDownloadSong: Bool = false

    func downloadSound(withId contentId: String) async throws {
        didCallDownloadSound = true
    }
    
    func downloadSong(withId contentId: String) async throws {
        didCallDownloadSong = true
    }
}
