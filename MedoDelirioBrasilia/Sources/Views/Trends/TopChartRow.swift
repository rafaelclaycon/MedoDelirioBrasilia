//
//  TopChartRow.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 29/05/22.
//

import SwiftUI

enum TopChartPlace {

    case first, second, third, other
}

struct TopChartRow: View {

    let item: TopChartItem

    private var isEven: Bool {
        if let idAsInt = Int(item.rankNumber), idAsInt.isMultiple(of: 2) {
            return true
        } else {
            return false
        }
    }
    
    private var cellFill: Color {
        if isEven {
            return .gray
        } else {
            return .clear
        }
    }

    private var showStripedList: Bool {
        UIDevice.isMac
    }

    private var isSpecialCase: Bool {
        ["1","2","3"].contains(item.rankNumber)
    }

    private var place: TopChartPlace {
        switch item.rankNumber {
        case "1": return .first
        case "2": return .second
        case "3": return .third
        default: return .other
        }
    }

    // MARK: - View Body

    var body: some View {
        VStack {
            if isSpecialCase {
                SpecialRow(item: item, place: place)
            } else {
                HStack(spacing: 15) {
                    NumberBadgeView(number: item.rankNumber, showBackgroundCircle: !showStripedList)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.contentName)
                            .bold()
                        Text(item.contentAuthorName)
                            .foregroundStyle(.gray)
                            .lineLimit(1)
                    }

                    Spacer()

                    Text("\(item.shareCount)")
                }
                .background(.background)
                .overlay {
                    if showStripedList {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(cellFill)
                            .opacity(0.2)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
    }
}

// MARK: - Subviews

extension TopChartRow {

    struct SpecialRow: View {

        let item: TopChartItem
        let place: TopChartPlace

        var body: some View {
            HStack(spacing: 15) {
                switch place {
                case .first:
                    Text("🥇")
                        .font(.system(size: 54))
                case .second:
                    Text("🥈")
                        .font(.system(size: 54))
                case .third:
                    Text("🥉")
                        .font(.system(size: 54))
                case .other:
                    EmptyView()
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(item.contentName)
                        .bold()
                    Text(item.contentAuthorName)
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                }

                Spacer()

                Text("\(item.shareCount)")
                    .bold(place == .first)
            }
            .background(.background)
        }
    }
}

// MARK: - Preview

#Preview {
    Group {
        TopChartRow(item: TopChartItem(
            id: "ABCD-EFGH",
            rankNumber: "1",
            contentId: "ABC",
            contentName: "Olha que imbecil",
            contentAuthorId: "DEF",
            contentAuthorName: "Bolsonaro",
            shareCount: 15
        ))
    }
}
