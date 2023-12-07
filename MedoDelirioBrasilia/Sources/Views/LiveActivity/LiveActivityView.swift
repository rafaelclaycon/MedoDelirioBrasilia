//
//  LiveActivityView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 05/12/23.
//

import SwiftUI

struct LiveActivityView: View {

    let state: SyncAttributes.ContentState

    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    LiveActivityView(state: .init(status: .updating))
}
