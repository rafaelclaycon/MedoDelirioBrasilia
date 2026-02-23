import SwiftUI

struct SupportPromptView: View {

    let onSupport: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: .spacing(.medium)) {
            Spacer()

            Image(systemName: "headphones")
                .font(.system(size: 50))
                .foregroundStyle(.green)

            Text("Curtindo os Episódios?")
                .font(.title2.bold())

            Text("O app é mantido por uma pessoa e é 100% grátis. Se você gosta, considere apoiar!")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, .spacing(.large))

            Spacer()

            VStack(spacing: .spacing(.small)) {
                Button(action: onSupport) {
                    Text("💚 Ver Como Apoiar")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.spacing(.small))
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Button(action: onDismiss) {
                    Text("Agora Não")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, .spacing(.small))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, .spacing(.large))
            .padding(.bottom, .spacing(.large))
        }
    }
}

#Preview {
    SupportPromptView(
        onSupport: {},
        onDismiss: {}
    )
}
