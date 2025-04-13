//
//  ToastView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/11/24.
//

import SwiftUI

public enum ToastType {
    
    case success, warning, wait, thankYou
}

public struct Toast {

    public let message: String
    public let type: ToastType

    public init(
        message: String,
        type: ToastType = .success
    ) {
        self.message = message
        self.type = type
    }
}

struct ToastView: ViewModifier {

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
        case .wait:
            "clock.fill"
        case .thankYou:
            ""
        case nil:
            ""
        }
    }

    private var iconColor: Color {
        switch toast?.type {
        case .success:
            .green
        case .warning:
            .orange
        case .wait:
            .orange
        case .thankYou:
            .pink
        case nil:
            .green
        }
    }

    public func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let toast {
                    Label {
                        Text(toast.message)
                            .foregroundColor(.black)
                            .font(.callout)
                            .bold()
                    } icon: {
                        Image(systemName: icon)
                            .font(Font.system(size: 20, weight: .bold))
                            .foregroundColor(iconColor)
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            self.toast = nil
                        }
                    }
                    .animation(.easeInOut, value: self.toast != nil)
                    //.transition(.moveAndFade)
                    .gesture(
                        DragGesture(minimumDistance: 30)
                            .onEnded { value in
                                if value.translation.height < 0 {
                                    self.toast = nil
                                }
                            }
                    )
                    .dynamicTypeSize(.xSmall ... .accessibility1)
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
        modifier(ToastView(toast))
    }
}

// MARK: - Previews

#Preview {
    Text("Show toast")
        .toast(.constant(Toast(message: "Toast message", type: .success)))
}

//#Preview {
//    VStack(spacing: .spacing(.large)) {
//        ToastView(
//            .constant(Toast(message: "Todos os dados atualizados.", type: .success))
//        )
//
//        ToastView(
//            .constant(Toast(message: "Conteúdo baixado com sucesso. Tente tocá-lo novamente.", type: .success))
//        )
//
//        ToastView(
//            .constant(Toast(message: "Atualização concluída com sucesso.", type: .success))
//        )
//
//        ToastView(
//            .constant(Toast(message: "Aguarde mais um pouco para atualizar novamente.", type: .wait))
//        )
//
//        ToastView(
//            .constant(Toast(message: "Som adicionado à pasta 🤑 Econoboys.", type: .success))
//        )
//    }
//}

// MARK: - Preference Key

public struct ToastPreferenceKey: PreferenceKey {

    public static var defaultValue: Bool = false

    public static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}
