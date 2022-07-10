import SwiftUI

struct FoldersAreTagsBannerView: View {

    var roundedRectangleHeight: CGFloat {
        switch UIScreen.main.bounds.width {
        case 320: // iPod touch 7
            return 204
        case 375: // iPhone 8
            return 164
        case 390: // iPhone 13
            return 160
        default: // iPhone 11, 13 Pro Max
            return 150
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.yellow)
                .frame(height: roundedRectangleHeight)
            
            HStack(spacing: 20) {
                Image(systemName: "lightbulb")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 7) {
                    Text("Dica")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text("Coloque um mesmo som em quantas pastas quiser. Apenas uma referência a ele será adicionada e ele continuará na lista principal.")
                        .foregroundColor(.black)
                        .opacity(0.9)
                }
                
                Spacer()
            }
            .padding(.leading, 20)
        }
    }

}

struct FoldersAreTagsBannerView_Previews: PreviewProvider {

    static var previews: some View {
        FoldersAreTagsBannerView()
    }

}
