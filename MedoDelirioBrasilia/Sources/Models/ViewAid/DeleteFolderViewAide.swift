//
//  DeleteFolderViewAid.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 29/09/22.
//

import Foundation

struct DeleteFolderViewAide {

    var alertTitle: String
    var alertMessage: String
    var showAlert: Bool
    var folderIdForDeletion: String
    
    init() {
        self.alertTitle = .empty
        self.alertMessage = .empty
        self.showAlert = false
        self.folderIdForDeletion = .empty
    }

}

class DeleteFolderViewAideiPhone: ObservableObject {

    @Published var alertTitle: String = .empty
    @Published var alertMessage: String = .empty
    @Published var showAlert: Bool = false
    @Published var folderIdForDeletion: String = .empty
    @Published var updateFolderList: Bool = false

}

class HighlightSoundAideiPad: ObservableObject {

    @Published var soundIdToGoTo: String = .empty

}
