//
//  SyncStatusView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 16/08/23.
//

import SwiftUI

struct SyncStatusView: View {

    @Environment(SyncValues.self) private var syncValues

    var body: some View {
        switch syncValues.syncStatus {
        case .updating:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        case .done:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.accentColor)
        case .updateError:
            Image(systemName: "exclamationmark.triangle.fill") // "xmark.octagon"
                .foregroundColor(.orange)
        case .pendingFirstUpdate:
            Image(systemName: "clock")
                .foregroundColor(.gray)
        }
    }
}

//struct SyncStatusView_Previews: PreviewProvider {
//
//    static let syncValuesUpdating: SyncValues = SyncValues()
//    static let syncValuesDone: SyncValues = SyncValues(syncStatus: .done)
//    static let syncValuesUpdateError: SyncValues = SyncValues(syncStatus: .updateError)
//
//    static var previews: some View {
//        Group {
//            SyncStatusView()
//                .environment(syncValuesUpdating)
//
//            SyncStatusView()
//                .environment(syncValuesDone)
//
//            SyncStatusView()
//                .environment(syncValuesUpdateError)
//        }
//    }
//}
