//
//  TopSelector.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 29/03/25.
//

import SwiftUI

struct TopSelector: View {

    @Binding var selected: TopSelectorOption

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Computed Properties

    private var selectedTextColor: Color {
        switch colorScheme {
        case .light:
            Color.whatsAppDarkGreen
        case .dark:
            Color.green
        @unknown default:
            Color.white
        }
    }

    private var notSelectedTextColor: Color {
        switch colorScheme {
        case .light:
            Color.black.opacity(0.6)
        case .dark:
            Color.white.opacity(0.6)
        @unknown default:
            Color.black.opacity(0.6)
        }
    }

    private var selectedBackgroundColor: Color {
        switch colorScheme {
        case .light:
            Color.whatsAppLightGreen
        case .dark:
            Color.green.opacity(0.3)
        @unknown default:
            Color.gray.opacity(0.15)
        }
    }

    private var notSelectedBackgroundColor: Color {
        switch colorScheme {
        case .light:
            Color.gray.opacity(0.1)
        case .dark:
            Color.gray.opacity(0.3)
        @unknown default:
            Color.gray.opacity(0.15)
        }
    }

    // MARK: - View Body

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(TopSelectorOption.allCases) { kind in
                    Text(kind.displayName)
                        .foregroundStyle(
                            kind == selected ? selectedTextColor : notSelectedTextColor
                        )
                        .font(.callout)
                        .fontWeight(.medium)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background {
                            RoundedRectangle(cornerRadius: 100)
                                .fill(
                                    kind == selected ? selectedBackgroundColor : notSelectedBackgroundColor
                                )
                        }
                        .onTapGesture {
                            selected = kind
                        }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 5)
        }
    }
}

#Preview {
    TopSelector(selected: .constant(.all))
        //.border(.blue.opacity(0.2), width: 1)
}
