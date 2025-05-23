//
//  UserFolder.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import Foundation

/// A model representing a user-defined folder with customizable attributes such as name, symbol, background color, and sorting preferences.
///
/// The `UserFolder` struct provides properties for displaying and managing user folders,
/// including support for synchronization and version control through a unique identifier
/// and change hash.
///
/// - Parameters:
///   - id: A unique identifier for the folder.
///   - symbol: An emoji picked by the user to represent the folder.
///   - name: The name of the folder, as defined by the user.
///   - backgroundColor: A pastel color name (custom app color) representing the folder's background color.
///   - changeHash: A hash string used to track changes to the folder, facilitating participation in Folder Research.
///   - creationDate: The date when the folder was created. This may be `nil` because at first Folders did not have it so very old versions do not have it.
///   - version: The version of the folder. Added so we can know if the folder supports sorting or not.
///   - userSortPreference: The user-defined sorting preference for folder content.
struct UserFolder: Hashable, Codable, Identifiable {

    let id: String
    var symbol: String
    var name: String
    var backgroundColor: String
    var changeHash: String?
    var creationDate: Date?
    var version: String?
    var userSortPreference: Int?
    var contentCount: Int?

    var isEmpty: Bool {
        guard let contentCount else { return true }
        return contentCount == 0
    }

    init(
        id: String = UUID().uuidString,
        symbol: String,
        name: String,
        backgroundColor: String,
        changeHash: String = "",
        creationDate: Date? = nil,
        version: String? = nil,
        userSortPreference: Int? = nil,
        contentCount: Int? = nil
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.backgroundColor = backgroundColor
        self.changeHash = changeHash
        self.creationDate = creationDate
        self.version = version
        self.userSortPreference = userSortPreference
        self.contentCount = contentCount
    }
}

extension UserFolder {

    static func newFolder() -> UserFolder {
        UserFolder(
            symbol: "",
            name: "",
            backgroundColor: Shared.Folders.defaultFolderColor,
            changeHash: "", // Has to be set to an actual hash before saving!
            creationDate: .now,
            version: "2" // Supports content sorting
        )
    }

    func folderHash(_ folderContents: [String]) -> String {
        let string = self.symbol + self.name + folderContents.joined()
        return FolderResearchProvider.hash(string)
    }
}
