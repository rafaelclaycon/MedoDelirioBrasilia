//
//  CreateFolderCell.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/01/23.
//

import SwiftUI

struct CreateFolderCell: View {

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.gray)
                    .frame(height: 90)
                    .opacity(0.15)
                
                Image(systemName: "folder.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 36)
                    .foregroundColor(.gray)
                    .opacity(0.7)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nova Pasta...")
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(.leading, 15)
        }
    }

}

struct CreateFolderCell_Previews: PreviewProvider {

    static var previews: some View {
        CreateFolderCell()
    }

}
