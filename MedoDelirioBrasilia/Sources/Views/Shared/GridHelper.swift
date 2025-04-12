import SwiftUI

class GridHelper {

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
