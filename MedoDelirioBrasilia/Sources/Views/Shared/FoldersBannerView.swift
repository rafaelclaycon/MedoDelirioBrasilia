import SwiftUI

struct FoldersBannerView: View {

    @Binding var displayMe: Bool
    
    var roundedRectangleHeight: CGFloat {
        switch UIScreen.main.bounds.width {
        case 320:
            return 220
        case 375:
            return 180
        case 390:
            return 176
        default:
            return 166
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.pastelBabyBlue)
                .frame(height: roundedRectangleHeight)
            
            HStack(spacing: 15) {
                Image(systemName: "folder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 7) {
                    Text("Apresentando: Pastas")
                        .font(.headline)
                        .foregroundColor(.mutedNavyBlue)
                    
                    Text("Tem muitos favoritos? Quer separar os áudios que manda no grupo da família e no grupo dos amigos? Crie pastas para agrupar sons na **aba Coleções > Minhas Pastas > Nova Pasta**.")
                        .foregroundColor(.mutedNavyBlue)
                        .opacity(0.75)
                }
                
                Spacer()
            }
            .padding(.leading, 20)
            
            VStack {
                HStack {
                    Spacer()
                    
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 17)
                        .foregroundColor(.blue)
                        .opacity(0.8)
                        .onTapGesture {
                            AppPersistentMemory.setFolderBannerWasDismissed(to: true)
                            displayMe = false
                        }
                }
                .padding(.trailing, 15)
                
                Spacer()
            }
            .padding(.top, 15)
        }
    }

}

struct FoldersBannerView_Previews: PreviewProvider {

    static var previews: some View {
        FoldersBannerView(displayMe: .constant(true))
    }

}
