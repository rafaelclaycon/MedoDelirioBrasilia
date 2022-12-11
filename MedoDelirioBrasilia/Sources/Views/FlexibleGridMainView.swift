//
//  FlexibleGridMainView.swift
//  MedoDelirioBrasilia
//
//  Created by Sergio Fernandes on 04/12/22.
//

import SwiftUI

struct GridItem: Identifiable {
    let id = UUID()
    let height: CGFloat
    let title: String
}

struct FlexibleGridMainView: View {
    
    struct Column: Identifiable {
        let id = UUID()
        var gridItems = [GridItem]()
    }
        let columns = [
        Column (gridItems: [
        GridItem(height: 200, title: "1"), GridItem(height: 50, title: "4"), GridItem(height: 100, title: "5"), GridItem(height: 500, title: "7"),
        ]),
        Column (gridItems: [
        GridItem(height: 50, title: "2"), GridItem(height: 300, title: "3"), GridItem(height: 100, title: "6"),
        ]),
        ]
    
    
    let spacing: CGFloat = 10
    let horizontalPadding: CGFloat = 10
    
    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            LazyVStack(spacing: spacing) {
                ForEach(0 ..< 30) { _ in
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(height: CGFloat.random(in: 20 ... 200))
                    
                }
            }
            
            LazyVStack(spacing: spacing) {
                ForEach(0 ..< 30) { _ in
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(height: CGFloat.random(in: 20 ... 200))
                    
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
    }
}

struct FlexibleGridMainView_Previews: PreviewProvider {
    static var previews: some View {
        FlexibleGridMainView()
    }
}
