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
                    Text("Tendências")
                }
                
                NavigationLink(destination: FolderResearchSettingsView()) {
                    Text("Pesquisa sobre as Pastas")
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
