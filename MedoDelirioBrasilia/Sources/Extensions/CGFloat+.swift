//
//  CGFloat+.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 23/11/24.
//

import Foundation

extension CGFloat {
    /// Create a spacing value from the Design System
    ///
    /// Spacing values should be used for padding, margins and denoting
    /// space between elements.
    ///
    /// - Parameter spacing: The core layout spacing value to use
    /// - Returns: The spacing value in points
    static func spacing(_ spacing: LayoutSpacing) -> CGFloat {
        spacing.value
    }

    enum LayoutSpacing: CaseIterable, Comparable, Hashable {
        /// core-space/nano - 2px
        case nano

        /// core-space/xxxs - 4px
        case xxxSmall

        /// core-space/xxs - 6px
        case xxSmall

        /// core-space/xs - 8px
        case xSmall

        /// core-space/s - 12px
        case small

        /// core-space/m - 16px
        case medium

        /// core-space/l - 20px
        case large

        /// core-space/xl - 24px
        case xLarge

        /// core-space/xxl - 32px
        case xxLarge

        /// core-space/xxxl - 40px
        case xxxLarge

        /// core-space/huge - 48px
        case huge

        /// The raw spacing value
        var value: CGFloat {
            switch self {
            case .nano:         return 2
            case .xxxSmall:     return 4
            case .xxSmall:      return 6
            case .xSmall:       return 8
            case .small:        return 12
            case .medium:       return 16
            case .large:        return 20
            case .xLarge:       return 24
            case .xxLarge:      return 32
            case .xxxLarge:     return 40
            case .huge:         return 48
            }
        }
    }
}
