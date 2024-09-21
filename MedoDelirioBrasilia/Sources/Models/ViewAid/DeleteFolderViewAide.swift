//
//  DeleteFolderViewAid.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 29/09/22.
//

import Foundation

class DeleteFolderViewAide: ObservableObject {

    @Published var alertTitle: String = .empty
    @Published var alertMessage: String = .empty
    @Published var showAlert: Bool = false
    @Published var folderIdForDeletion: String = .empty
    @Published var updateFolderList: Bool = false
}
