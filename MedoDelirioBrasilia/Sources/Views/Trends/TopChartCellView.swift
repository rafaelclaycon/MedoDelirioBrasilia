import SwiftUI

struct TopChartCellView: View {

    @State var item: TopChartItem
    
    private let circleDiameter: CGFloat = 30
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack() {
                Circle()
                    .fill(.gray)
                    .frame(width: circleDiameter, height: circleDiameter)
                    .opacity(0.5)
                
                Text(item.id)
                    .foregroundColor(.primary)
                    .bold()
            }
            
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
        TopChartCellView(item: TopChartItem(id: "1", contentId: "ABC", contentName: "Olha que imbecil", contentAuthorId: "DEF", contentAuthorName: "Bolsonaro", shareCount: 15))
    }

}
