//
//  TopChartCellView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 29/05/22.
//

import SwiftUI

struct TopChartCellView: View {

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
        ZStack {
            if UIDevice.isMac {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(cellFill)
                    .opacity(0.2)
            }
            
            HStack(spacing: 15) {
                NumberBadgeView(number: item.rankNumber, showBackgroundCircle: !UIDevice.isMac)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.contentName)
                        .bold()
                    Text(item.contentAuthorName)
                }
                
                Spacer()
                
                Text("\(item.shareCount)")
            }
            .padding(.horizontal)
        }
    }

}

struct TopChartCellView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            TopChartCellView(item: TopChartItem(id: "1",
                                                rankNumber: "ABCD-EFGH",
                                                contentId: "ABC",
                                                contentName: "Olha que imbecil",
                                                contentAuthorId: "DEF",
                                                contentAuthorName: "Bolsonaro",
                                                shareCount: 15))
        }
        .previewLayout(.fixed(width: 300, height: 100))
    }

}
