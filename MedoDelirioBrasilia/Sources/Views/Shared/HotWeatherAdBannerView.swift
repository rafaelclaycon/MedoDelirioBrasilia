import SwiftUI

struct HotWeatherAdBannerView: View {

    @Binding var displayMe: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var roundedRectangleHeight: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            switch UIScreen.main.bounds.width {
            case 320: // iPhone SE 1
                return 510
            case 375: // iPhone 8
                return 500
            case 390: // iPhone 12/13
                return 475
            case 428: // iPhone 13 Pro Max
                return 380
            default: // iPhone 11/8 Plus
                return 400
            }
        } else { // iPad/Mac
            return 200
        }
    }
    
    var adTitle: String {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return "Tempo Quente"
        } else {
            return "Tempo Quente - um podcast original da Rádio Novelo"
        }
    }
    
    var adBody: String {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return "O Brasil tinha tudo pra ser uma potência ambiental, mas tá ficando cada vez mais pra trás. A ciência alerta há décadas sobre a emergência climática, mas ninguém faz nada pra mudar. Agora: quem é que tá ganhando com isso?"
        } else {
            return "O Brasil tinha tudo pra ser uma potência ambiental, mas tá ficando cada vez mais pra trás. A ciência alerta há décadas sobre a emergência climática, mas ninguém faz nada pra mudar. Tá todo mundo perdendo nessa história – e isso a gente sabe. Agora: quem é que tá ganhando?"
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.gray)
                .frame(height: roundedRectangleHeight)
                .opacity(colorScheme == .dark ? 0.3 : 0.1)
            
            HStack(spacing: 20) {
                VStack {
                    Image("tempo_quente_capa")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIDevice.is4InchDevice ? 50 : 100)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        .shadow(radius: 5)
                        .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 15 : 0)
                    
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        Spacer()
                    }
                }
                
                VStack(alignment: .leading, spacing: 7) {
                    Text(adTitle)
                        .font(.headline)
                    
                    Text(adBody)
                        .foregroundColor(.primary)
                        .opacity(0.75)
                    
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        VStack(alignment: .leading, spacing: 15) {
                            viewOnButtons()
                        }
                        .padding(.top, 3)
                    } else {
                        HStack(spacing: 24) {
                            viewOnButtons()
                        }
                        .padding(.top, 3)
                    }
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
                        .foregroundColor(.primary)
                        .opacity(0.8)
                        .onTapGesture {
                            UserSettings.setHotWeatherBannerWasDismissed(to: true)
                            displayMe = false
                        }
                }
                .padding(.trailing, 15)
                
                Spacer()
            }
            .padding(.top, 15)
        }
    }
    
    @ViewBuilder func viewOnButtons() -> some View {
        Button {
            guard let url = URL(string: "https://open.spotify.com/show/5g1iYnkOFGdve9eAr8Ag43") else { return }
            UIApplication.shared.open(url)
        } label: {
            Text("Ver no Spotify")
                .padding(.horizontal, UIDevice.is4InchDevice ? 4 : 6)
        }
        .tint(colorScheme == .dark ? .green : .darkerGreen)
        //.controlSize(.regular)
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle)
        
        Button {
            guard let url = URL(string: "https://podcasts.apple.com/br/podcast/tempo-quente/id1625594176") else { return }
            UIApplication.shared.open(url)
        } label: {
            Text("Ver no Apple Podcasts")
                .padding(.horizontal, UIDevice.is4InchDevice ? 6 : 6)
        }
        .tint(.purple)
        //.controlSize(.regular)
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle)
        
        Button {
            guard let url = URL(string: "https://pca.st/podcast/c61227f0-bc42-013a-d913-0acc26574db2") else { return }
            UIApplication.shared.open(url)
        } label: {
            Text("Ver no Pocket Casts")
                .padding(.horizontal, UIDevice.is4InchDevice ? 6 : 6)
        }
        .tint(.red)
        //.controlSize(.regular)
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle)
    }

}

struct HotWeatherAdBannerView_Previews: PreviewProvider {

    static var previews: some View {
        HotWeatherAdBannerView(displayMe: .constant(true))
    }

}
