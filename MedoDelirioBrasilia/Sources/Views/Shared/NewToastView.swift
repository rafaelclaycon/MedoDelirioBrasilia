//
//  NewToastView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/11/24.
//

import SwiftUI

public enum ToastType {
    case success, warning, pleaseWait
}

public struct Toast {

    public let message: String
    public let type: ToastType
    public let edge: Alignment

    public init(
        message: String,
        type: ToastType = .success,
        edge: Alignment = .bottom
    ) {
        self.message = message
        self.type = type
        self.edge = edge
    }
}

struct NewToastView: ViewModifier {

    @Binding private var toast: Toast?

    public init(_ toast: Binding<Toast?>) {
        _toast = toast
    }

    private var icon: String {
        switch toast?.type {
        case .success:
            "checkmark"
        case .warning:
            "exclamationmark.triangle.fill"
        case .pleaseWait:
            "clock.fill"
        case nil:
            ""
        }
    }

    public func body(content: Content) -> some View {
        content
            .overlay(alignment: toast?.edge ?? .bottom) {
                if let toast {
                    Label {
                        Text(toast.message)
                            .foregroundColor(.black)
                            .font(.callout)
                            .bold()
                    } icon: {
                        Image(systemName: icon)
                            .font(Font.system(size: 20, weight: .bold))
                            .foregroundColor(toast.type == .success ? .green : .orange)
                    }
                    .labelStyle(.centerAligned)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: 50, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: .gray, radius: 2, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 15)
                    .dynamicTypeSize(.xSmall ... .accessibility1)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.toast = nil
                        }
                    }
                    .animation(.easeInOut, value: self.toast != nil)
                    .gesture(
                        DragGesture(minimumDistance: 30)
                            .onEnded { value in
                                if value.translation.height < 0 {
                                    self.toast = nil
                                }
                            }
                    )
                }
            }
    }
}

// MARK: - Modifiers

public extension View {

    /// Sets the `ToastPreferenceKey` with the given `value`.
    /// - Parameters:
    ///   - value: The value to be set.
    func showToast(_ value: Bool) -> some View {
        preference(key: ToastPreferenceKey.self, value: value)
    }

    /// Adds a `ToastView` to the view's safe area inset.
    /// - Parameters:
    ///   - toast: Binding to a toast to display. When nil, toast is not presented.
    func toast(_ toast: Binding<Toast?>) -> some View {
        modifier(NewToastView(toast))
    }
}

// MARK: - Preview

#Preview {
    Text("Show toast")
        .toast(.constant(Toast(message: "Toast message", type: .success, edge: .bottom)))
}

// MARK: - Preference Key

public struct ToastPreferenceKey: PreferenceKey {

    public static var defaultValue: Bool = false

    public static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}
