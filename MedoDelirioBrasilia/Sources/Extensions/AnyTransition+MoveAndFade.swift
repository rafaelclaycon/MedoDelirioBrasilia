import SwiftUI

extension AnyTransition {

    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity
        )
    }

    static var slideFromLeading: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal: .opacity
        )
    }
}
