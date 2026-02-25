import SwiftUI

struct EpisodeNotificationsBannerView: View {

    @Binding var isBeingShown: Bool

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing(.medium)) {
            HStack {
                Label("Novos Episódios", systemImage: "bell.badge")
                    .foregroundStyle(
                        colorScheme == .dark ? Color.primary : Color.darkestGreen
                    )
                    .bold()

                Spacer()
                    .frame(width: 30)
            }

            Text("Receba uma notificação sempre que um novo episódio do podcast estiver disponível.")
                .foregroundStyle(
                    colorScheme == .dark ? Color.primary : Color.darkestGreen
                )
                .opacity(0.8)
                .font(.callout)

            if #available(iOS 26, *) {
                Button {
                    // TODO: Call episode notifications opt-in endpoint
                    UserSettings().setEnableEpisodeNotifications(to: true)
                    isBeingShown = false
                } label: {
                    Text("Quero Receber")
                        .font(.callout)
                        .bold()
                        .foregroundStyle(
                            colorScheme == .dark ? .primary : Color.darkestGreen
                        )
                        .padding(.vertical, .spacing(.small))
                        .frame(maxWidth: .infinity)
                        .glassEffect(
                            .regular.interactive()
                        )
                }
            } else {
                Button {
                    // TODO: Call episode notifications opt-in endpoint
                    UserSettings().setEnableEpisodeNotifications(to: true)
                    isBeingShown = false
                } label: {
                    Text("Quero Receber")
                        .font(.callout)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, .spacing(.xxSmall))
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.all, 20)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.green)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                AppPersistentMemory.shared.setHasDismissedEpisodeNotificationsBanner(to: true)
                isBeingShown = false
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(
                        colorScheme == .dark ? .green : Color.darkestGreen
                    )
            }
            .padding()
        }
    }
}

#Preview {
    EpisodeNotificationsBannerView(isBeingShown: .constant(true))
        .padding()
}
