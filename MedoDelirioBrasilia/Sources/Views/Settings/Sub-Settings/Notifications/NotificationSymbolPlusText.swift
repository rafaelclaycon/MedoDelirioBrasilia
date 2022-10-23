import SwiftUI

struct NotificationSymbolPlusText: View {

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            NotificationsSymbol()
            
            Text("Receba avisos sobre os **últimos sons, tendências e novos recursos**.\n\nFrequência de envio: baixa, no máximo 2 notificações por semana.")
                .multilineTextAlignment(.center)
        }
    }

}

struct NotificationSymbolPlusText_Previews: PreviewProvider {

    static var previews: some View {
        NotificationSymbolPlusText()
    }

}
