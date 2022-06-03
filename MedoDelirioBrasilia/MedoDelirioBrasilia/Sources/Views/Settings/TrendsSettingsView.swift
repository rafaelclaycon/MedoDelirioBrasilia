import SwiftUI

struct TrendsSettingsView: View {

    @State var test = true
    @State var trendsEnabled = true
    
    var body: some View {
        Form {
            Section {
                Toggle("Habilitar Tendências", isOn: $trendsEnabled)
                    .onChange(of: test) { newValue in
                        //UserSettings.setSkipGetLinkInstructions(to: newValue)
                        //isTrendsEnabled = newValue
                    }
            } footer: {
                Text("Nenhum dado coletado identifica você. O propósito dessa funcionalidade é apenas matar a sua curiosidade e a dos demais usuários sobre a popularidade dos sons.")
            }
            
            Section {
                Toggle("Sons Mais Compartilhados Por Mim", isOn: $test)
//                    .onChange(of: viewModel.displayHowToGetLinkInstructions) { newValue in
//                        UserSettings.setSkipGetLinkInstructions(to: newValue)
//                    }
                Toggle("Dia da semana no qual você mais compartilha (em breve)", isOn: $test)
                Toggle("Sons Mais Compartilhados Pela Audiência (em breve)", isOn: $test)
                Toggle("Apps Pelos Quais Você Mais Compartilha", isOn: $test)
                Toggle("Compartilhar minhas tendências", isOn: $test)
            } header: {
                Text("Escolha o que deseja usar")
            } footer: {
                Text("Confira os dados enviados, SE a opção acima estivar ativada: ID de instalação, ID do conteúdo compartilhado, tipo do conteúdo (som ou música), data e hora do compartilhamento, nome do app pelo qual o conteúdo foi compartilhado.")
            }
            //.disabled(trendsEnabled == false)
            
            Section("Apagar logs") {
                Button("Limpar todos os registros locais") {
                    try? database.deleteAllShareLogs()
                }
            }
        }
        .navigationTitle("Ajustes das Tendências")
        .navigationBarTitleDisplayMode(.inline)
    }

}

struct TrendsSettingsView_Previews: PreviewProvider {

    static var previews: some View {
        TrendsSettingsView()
    }

}
