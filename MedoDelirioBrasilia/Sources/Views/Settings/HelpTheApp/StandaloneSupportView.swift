import SwiftUI

struct StandaloneSupportView: View {

    @State private var toast: Toast?
    @State private var animateGradient: Bool = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: .spacing(.xLarge)) {
                    header

                    HelpTheAppView.DonateButtons(toast: $toast, showSectionDivider: true)
                        .padding(.horizontal, .spacing(.large))
                }
                .padding(.bottom, .spacing(.xLarge))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton {
                        dismiss()
                    }
                }
            }
        }
        .toast($toast)
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            RoundedRectangle(cornerRadius: .spacing(.medium))
                .fill(
                    LinearGradient(
                        colors: animateGradient
                            ? [.green, .mint, .green.opacity(0.7)]
                            : [.mint, .green, .mint.opacity(0.7)],
                        startPoint: animateGradient ? .topLeading : .bottomLeading,
                        endPoint: animateGradient ? .bottomTrailing : .topTrailing
                    )
                )
                .onAppear {
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        animateGradient = true
                    }
                }

            VStack(spacing: .spacing(.large)) {
                Image("marketing-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: .black.opacity(0.25), radius: 8, y: 4)

                Text("Sem anúncios. Sem rastreamento.\nSem firula.")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, .spacing(.xLarge))
        }
        .padding(.horizontal, .spacing(.large))
        .padding(.top, .spacing(.small))
    }
}

// MARK: - Preview

#Preview {
    StandaloneSupportView()
}
