//
//  FolderColor.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

struct FolderColor: Identifiable {

    var id: String
    var color: Color
    
    init(id: String, color: Color) {
        self.id = id
        self.color = color
    }

}

class FolderColorFactory {

    static func getColors() -> [FolderColor] {
        var colors = [FolderColor]()
        colors.append(FolderColor(id: "pastelPurple", color: .pastelPurple))
        colors.append(FolderColor(id: "pastelBabyBlue", color: .pastelBabyBlue))
        colors.append(FolderColor(id: "pastelBrightGreen", color: .pastelBrightGreen))
        colors.append(FolderColor(id: "pastelYellow", color: .pastelYellow))
        colors.append(FolderColor(id: "pastelOrange", color: .pastelOrange))
        colors.append(FolderColor(id: "pastelPink", color: .pastelPink))
        colors.append(FolderColor(id: "pastelGray", color: .pastelGray))
        colors.append(FolderColor(id: "pastelRoyalBlue", color: .pastelRoyalBlue))
        colors.append(FolderColor(id: "pastelMutedGreen", color: .pastelMutedGreen))
        colors.append(FolderColor(id: "pastelRed", color: .pastelRed))
        colors.append(FolderColor(id: "pastelBeige", color: .pastelBeige))
        return colors
    }

}
