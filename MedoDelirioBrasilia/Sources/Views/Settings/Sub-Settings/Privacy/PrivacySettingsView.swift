//
//  PrivacySettingsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 24/10/22.
//

import SwiftUI

struct PrivacySettingsView: View {

    var body: some View {
        Form {
            Section {
                NavigationLink(destination: TrendsSettingsView()) {
                    Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
                }
                
                NavigationLink(destination: FolderResearchSettingsView()) {
                    Label {
                        Text("Pesquisa sobre as Pastas")
                    } icon: {
                        Image(systemName: "folder")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationTitle("Privacidade")
        .navigationBarTitleDisplayMode(.inline)
    }

}

struct PrivacySettingsView_Previews: PreviewProvider {

    static var previews: some View {
        PrivacySettingsView()
    }

}
