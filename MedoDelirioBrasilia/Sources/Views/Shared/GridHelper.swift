import SwiftUI

class GridHelper {

    static func soundColumns(listWidth: CGFloat, sizeCategory: ContentSizeCategory) -> [GridItem] {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if sizeCategory > ContentSizeCategory.medium {
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

}
