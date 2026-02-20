//
//  View+.swift
//  MedoDelirioBrasilia
//
//  Created by Antoine van der Lee on 30/09/23.
//

import SwiftUI

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Conditionally applies `tabViewBottomAccessory` using the `isEnabled` parameter on iOS 26.1+,
    /// falling back to the `.if` conditional modifier on iOS 26.0.
    @available(iOS 26.0, *)
    @ViewBuilder func if_tabViewBottomAccessory<Accessory: View>(
        isEnabled: @autoclosure () -> Bool,
        @ViewBuilder content: @escaping () -> Accessory
    ) -> some View {
        if #available(iOS 26.1, *) {
            self.tabViewBottomAccessory(isEnabled: isEnabled()) {
                content()
            }
        } else {
            self.if(isEnabled()) { view in
                view.tabViewBottomAccessory {
                    content()
                }
            }
        }
    }
}
