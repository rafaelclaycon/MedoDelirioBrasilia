//
//  SyncStatusView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 16/08/23.
//

import SwiftUI

struct SyncStatusView: View {
    @EnvironmentObject private var syncValues: SyncValues

    var body: some View {
        switch syncValues.syncStatus {
        case .updating:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        case .done:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.accentColor)
        case .noInternet:
            Image(systemName: "exclamationmark.octagon")
                .foregroundColor(.gray)
        case .updateError:
            Image(systemName: "exclamationmark.triangle.fill") // "xmark.octagon"
                .foregroundColor(.orange)
        }
    }
}

struct SyncStatusView_Previews: PreviewProvider {
    static let syncValuesUpdating: SyncValues = SyncValues()
    static let syncValuesDone: SyncValues = SyncValues(syncStatus: .done)
    static let syncValuesNoInternet: SyncValues = SyncValues(syncStatus: .noInternet)
    static let syncValuesUpdateError: SyncValues = SyncValues(syncStatus: .updateError)

    static var previews: some View {
        Group {
            SyncStatusView()
                .environmentObject(syncValuesUpdating)

            SyncStatusView()
                .environmentObject(syncValuesDone)

            SyncStatusView()
                .environmentObject(syncValuesNoInternet)

            SyncStatusView()
                .environmentObject(syncValuesUpdateError)
        }
    }
}
