import SwiftUI

class GridHelper {

    static func adaptableColumns(
        listWidth: CGFloat,
        sizeCategory: ContentSizeCategory,
        spacing: CGFloat
    ) -> [GridItem] {
        if UIDevice.isiPhone {
            if sizeCategory > ContentSizeCategory.large {
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

    static func authorColumns(
        gridWidth: CGFloat,
        spacing: CGFloat
    ) -> [GridItem] {
        if UIDevice.isiPhone {
            return [
                GridItem(.flexible(), spacing: spacing, alignment: .center)
            ]
        } else {
            if gridWidth < 600 {
                return [
                    GridItem(.flexible(), spacing: spacing, alignment: .center)
                ]
            } else if gridWidth < 850 {
                return [
                    GridItem(.flexible(), spacing: spacing, alignment: .center),
                    GridItem(.flexible(), spacing: spacing, alignment: .center)
                ]
            } else if gridWidth < 1200 {
                return [
                    GridItem(.flexible(), spacing: spacing, alignment: .center),
                    GridItem(.flexible(), spacing: spacing, alignment: .center),
                    GridItem(.flexible(), spacing: spacing, alignment: .center)
                ]
            } else if gridWidth < 2000 {
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
