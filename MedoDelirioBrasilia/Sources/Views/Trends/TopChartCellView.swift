import SwiftUI

struct TopChartCellView: View {

    @State var item: TopChartItem
    
    var body: some View {
        HStack(spacing: 15) {
            NumberBadgeView(number: item.id)
            
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

struct TopChartCellView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            TopChartCellView(item: TopChartItem(id: "1",
                                                contentId: "ABC",
                                                contentName: "Olha que imbecil",
                                                contentAuthorId: "DEF",
                                                contentAuthorName: "Bolsonaro",
                                                shareCount: 15))
        }
        .previewLayout(.fixed(width: 300, height: 100))
    }

}
