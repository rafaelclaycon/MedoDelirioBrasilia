//
//  SidebarFolderIcon.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/07/22.
//

import SwiftUI

struct SidebarFolderIcon: View {

    @State var symbol: String
    @State var backgroundColor: Color
    @State var size: CGFloat = 40
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(backgroundColor)
                .frame(width: size, height: size)
            
            Text(symbol)
        }
    }

}

struct SidebarFolderIcon_Previews: PreviewProvider {

    static var previews: some View {
        SidebarFolderIcon(symbol: "😎", backgroundColor: .pastelBabyBlue)
    }

}
