//
//  NoAuthorPhotoView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 02/02/24.
//

import SwiftUI

struct NoAuthorPhotoView: View {

    var body: some View {
        Image(systemName: "photo.on.rectangle")
            .resizable()
            .scaledToFit()
            .frame(height: 100)
            .foregroundColor(.gray)
            .opacity(0.3)
    }
}

#Preview {
    NoAuthorPhotoView()
}
