//
//  FolderResearchSettings.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 24/10/22.
//

import SwiftUI

struct FolderResearchSettingsView: View {

    @State var trendsEnabled = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Participar da Pesquisa", isOn: $trendsEnabled)
                    .onChange(of: trendsEnabled) { newValue in
                        UserSettings.setEnableTrends(to: newValue)
                    }
            } footer: {
                Text("Nenhum dado coletado identifica você.\n\nAo enviar informações das suas pastas anonimamente, você me ajuda a entender o uso dessa funcionalidade para que eu possa melhorá-la no futuro.\n\nA pesquisa consiste em enviar os seguintes dados para o servidor do Medo e Delírio iOS:\n · ID de instalação do app (não contém nenhum nome; é renovado ao desintalar e reinstalar o app)\n · Símbolo, cor e nome das pastas\n · IDs dos sons inseridos nas pastas\n\nNenhum som será enviado, portanto o consumo de dados será mínimo.")
            }
            
            Section {
                Button("Solicitar a exclusão dos meus dados") {
                    //showEmailClientConfirmationDialog = true
                }
            }
        }
        .navigationTitle("Pesquisa sobre as Pastas")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            //trendsEnabled = UserSettings.getEnableTrends()
        }
    }

}

struct FolderResearchSettingsView_Previews: PreviewProvider {

    static var previews: some View {
        FolderResearchSettingsView()
    }

}
