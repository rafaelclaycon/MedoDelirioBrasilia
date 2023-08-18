//
//  SyncStatusView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 16/08/23.
//

import SwiftUI

struct SyncStatusView: View {
    @Binding var isLoading: Bool

    var body: some View {
        if isLoading {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        } else {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.accentColor)
        }
    }
}

struct SyncStatusView_Previews: PreviewProvider {
    static var previews: some View {
        SyncStatusView(isLoading: .constant(true))
    }
}
