import SwiftUI

struct TrendsSettingsView: View {

    @State var trendsEnabled = UserSettings.getEnableTrends()
    @State var mostSharedSoundsByTheUserEnabled = UserSettings.getEnableMostSharedSoundsByTheUser()
    @State var dayOfTheWeekTheUserSharesTheMostEnabled = UserSettings.getEnableDayOfTheWeekTheUserSharesTheMost()
    @State var soundsMostSharedByTheAudienceEnabled = UserSettings.getEnableSoundsMostSharedByTheAudience()
    @State var appsThroughWhichTheUserSharesTheMostEnabled = UserSettings.getEnableAppsThroughWhichTheUserSharesTheMost()
    @State var shareUserPersonalTrendsEnabled = UserSettings.getEnableShareUserPersonalTrends()
    
    var body: some View {
        Form {
            Section {
                Toggle("Habilitar Tendências", isOn: $trendsEnabled)
                    .onChange(of: trendsEnabled) { newValue in
                        UserSettings.setEnableTrends(to: newValue)
                    }
            } footer: {
                Text("Nenhum dado coletado identifica você. O propósito dessa funcionalidade é apenas matar a sua curiosidade e a dos demais usuários sobre a popularidade dos sons.")
            }
            
            Section {
                Toggle("Sons Mais Compartilhados Por Mim", isOn: $mostSharedSoundsByTheUserEnabled)
                    .onChange(of: mostSharedSoundsByTheUserEnabled) { newValue in
                        UserSettings.setEnableMostSharedSoundsByTheUser(to: newValue)
                    }
                Toggle("Dia da semana no qual você mais compartilha", isOn: $dayOfTheWeekTheUserSharesTheMostEnabled)
                    .onChange(of: dayOfTheWeekTheUserSharesTheMostEnabled) { newValue in
                        UserSettings.setEnableDayOfTheWeekTheUserSharesTheMost(to: newValue)
                    }
                Toggle("Sons Mais Compartilhados Pela Audiência (Beta)", isOn: $soundsMostSharedByTheAudienceEnabled)
                    .onChange(of: soundsMostSharedByTheAudienceEnabled) { newValue in
                        UserSettings.setEnableSoundsMostSharedByTheAudience(to: newValue)
                    }
                Toggle("Apps Pelos Quais Você Mais Compartilha", isOn: $appsThroughWhichTheUserSharesTheMostEnabled)
                    .onChange(of: appsThroughWhichTheUserSharesTheMostEnabled) { newValue in
                        UserSettings.setEnableAppsThroughWhichTheUserSharesTheMost(to: newValue)
                    }
                Toggle("Compartilhar minhas tendências", isOn: $shareUserPersonalTrendsEnabled)
                    .onChange(of: shareUserPersonalTrendsEnabled) { newValue in
                        UserSettings.setEnableShareUserPersonalTrends(to: newValue)
                    }
            } header: {
                Text("Escolha o que deseja usar")
            } footer: {
                Text("Confira os dados enviados SE a opção acima estivar ativada: ID de instalação, ID do conteúdo compartilhado, tipo do conteúdo (som ou música), quantidade total de compartilhamentos, nome do app pelo qual o conteúdo foi compartilhado.")
            }
            .disabled(trendsEnabled == false)
            
            Section("Histórico local de compartilhamento") {
                Button("Apagar todos os registros locais") {
                    try? database.deleteAllUserShareLogs()
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
