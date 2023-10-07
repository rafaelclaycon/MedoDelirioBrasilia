//
//  TopChartRow.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 29/05/22.
//

import SwiftUI

struct TopChartRow: View {

    @State var item: TopChartItem
    
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
    
    var body: some View {
        HStack(spacing: 15) {
            NumberBadgeView(number: item.rankNumber, showBackgroundCircle: !UIDevice.isMac)

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
        .padding(.horizontal)
        .padding(.vertical, 14)
        .background(.background)
        .overlay {
            if UIDevice.isMac {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(cellFill)
                    .opacity(0.2)
            }
        }
    }
}

struct TopChartCellView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            TopChartRow(item: TopChartItem(id: "ABCD-EFGH",
                                                rankNumber: "1",
                                                contentId: "ABC",
                                                contentName: "Olha que imbecil",
                                                contentAuthorId: "DEF",
                                                contentAuthorName: "Bolsonaro",
                                                shareCount: 15))
        }
        .previewLayout(.fixed(width: 300, height: 100))
    }
}
