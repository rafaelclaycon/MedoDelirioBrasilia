//
//  DeleteFolderViewAid.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 29/09/22.
//

import Foundation

class DeleteFolderViewAide: ObservableObject {

    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var folderIdForDeletion: String = ""
    @Published var updateFolderList: Bool = false
}
