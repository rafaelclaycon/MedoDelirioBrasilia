import SwiftUI

class GridHelper {

    @available(*, deprecated, message: "Kept just to avoid breaking old code. Use adaptableColumns() instead.")
    static func soundColumns(listWidth: CGFloat, sizeCategory: ContentSizeCategory) -> [GridItem] {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if sizeCategory > ContentSizeCategory.large {
                return [
                    GridItem(.flexible())
                ]
            } else {
                return [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]
            }
        } else {
            if listWidth < 500 {
                return [
                    GridItem(.flexible())
                ]
            } else if listWidth < 600 {
                return [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]
            } else if listWidth < 705 {
                return [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]
            } else {
                return [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]
            }
        }
    }

    static func adaptableColumns(
        listWidth: CGFloat,
        sizeCategory: ContentSizeCategory,
        spacing: CGFloat,
        forceSingleColumnOnPhone: Bool = false
    ) -> [GridItem] {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if forceSingleColumnOnPhone || sizeCategory > ContentSizeCategory.large {
                return [
                    GridItem(.flexible(), spacing: spacing, alignment: .center)
                ]
            } else {
                return [
                    GridItem(.flexible(), spacing: spacing, alignment: .center),
                    GridItem(.flexible(), spacing: spacing, alignment: .center)
                ]
            }
        } else {
            if listWidth < 500 {
                return [
                    GridItem(.flexible(), spacing: spacing, alignment: .center)
                ]
            } else if listWidth < 600 {
                return [
                    GridItem(.flexible(), spacing: spacing, alignment: .center),
                    GridItem(.flexible(), spacing: spacing, alignment: .center)
                ]
            } else if listWidth < 870 {
                return [
                    GridItem(.flexible(), spacing: spacing, alignment: .center),
                    GridItem(.flexible(), spacing: spacing, alignment: .center),
                    GridItem(.flexible(), spacing: spacing, alignment: .center)
                ]
            } else if listWidth < 1200 {
                return [
                    GridItem(.flexible(), spacing: spacing, alignment: .center),
                    GridItem(.flexible(), spacing: spacing, alignment: .center),
                    GridItem(.flexible(), spacing: spacing, alignment: .center),
                    GridItem(.flexible(), spacing: spacing, alignment: .center)
                ]
            } else {
                return [
                    GridItem(.flexible(), spacing: spacing, alignment: .center),
                    GridItem(.flexible(), spacing: spacing, alignment: .center),
                    GridItem(.flexible(), spacing: spacing, alignment: .center),
                    GridItem(.flexible(), spacing: spacing, alignment: .center),
                    GridItem(.flexible(), spacing: spacing, alignment: .center)
                ]
            }
        }
    }
}
