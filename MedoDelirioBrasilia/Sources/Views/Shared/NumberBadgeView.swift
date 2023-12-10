import SwiftUI

struct NumberBadgeView: View {

    let number: String
    let showBackgroundCircle: Bool
    var lightModeOpacity: Double = 0.25
    var darkModeOpacity: Double = 0.5

    @Environment(\.colorScheme) var colorScheme

    private let circleHeight: CGFloat = 30

    private var circleWidth: CGFloat {
        if number.count > 2 {
            return 40
        } else {
            return 30
        }
    }

    var body: some View {
        ZStack() {
            RoundedRectangle(cornerRadius: 30)
                .fill(showBackgroundCircle ? .gray : .clear)
                .frame(width: circleWidth, height: circleHeight)
                .opacity(colorScheme == .dark ? darkModeOpacity : lightModeOpacity)

            Text(number)
                .bold()
        }
    }
}

#Preview {
    Group {
        NumberBadgeView(number: "1", showBackgroundCircle: true)
        NumberBadgeView(number: "10", showBackgroundCircle: false)
        NumberBadgeView(number: "55", showBackgroundCircle: true)
        NumberBadgeView(number: "99", showBackgroundCircle: false)
        NumberBadgeView(number: "100", showBackgroundCircle: true)
    }
    .previewLayout(.fixed(width: 70, height: 60))
}
