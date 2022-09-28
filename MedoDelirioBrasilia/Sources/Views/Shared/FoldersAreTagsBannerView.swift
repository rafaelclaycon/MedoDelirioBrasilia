import SwiftUI

struct FoldersAreTagsBannerView: View {

    @Environment(\.colorScheme) var colorScheme
    
    var roundedRectangleHeight: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
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
        } else {
            return 100
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.gray)
                .frame(height: roundedRectangleHeight)
                .opacity(colorScheme == .dark ? 0.3 : 0.1)
            
            HStack(spacing: 20) {
                Image(systemName: "lightbulb")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 7) {
                    Text("Dica")
                        .font(.headline)
                    
                    Text("Coloque um mesmo som em quantas pastas quiser. Apenas uma referência a ele será adicionada e ele continuará disponível na lista principal.")
                        .opacity(0.75)
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
