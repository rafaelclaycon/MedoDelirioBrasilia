//
//  DeleteFolderViewAid.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 29/09/22.
//

import Foundation

@Observable
class DeleteFolderViewAide {

    var alertTitle: String = ""
    var alertMessage: String = ""
    var showAlert: Bool = false
    var folderIdForDeletion: String = ""
    var updateFolderList: Bool = false
}
