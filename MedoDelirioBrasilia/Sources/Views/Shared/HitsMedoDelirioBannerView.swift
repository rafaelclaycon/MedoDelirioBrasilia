import SwiftUI

struct HitsMedoDelirioBannerView: View {

    var roundedRectangleHeight: CGFloat {
        return 150
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.hitsMedoDelirioSpotify)
                .frame(height: roundedRectangleHeight)
            
            HStack(spacing: 20) {
                VStack {
                    Image("hits_medo_delirio_artwork")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIDevice.is4InchDevice ? 50 : 100)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        .padding(.top, UIDevice.current.userInterfaceIdiom == .phone ? 15 : 0)
                    
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        Spacer()
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("HITS Medo e Delírio no Spotify")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Sabia que algumas músicas do podcast estão no Spotify? Curta lá e aproveite para usar nos Stories!")
                        .foregroundColor(.white)
                        .opacity(0.85)
                    
                    Button {
                        guard let url = URL(string: "https://open.spotify.com/artist/2zEW74UlVEJGtC13rYkzJF?si=ElW6VmcvQ_etlGmBv_UGhw") else { return }
                        UIApplication.shared.open(url)
                    } label: {
                        Text("Ouvir no Spotify")
                            .padding(.horizontal, UIDevice.is4InchDevice ? 4 : 6)
                    }
                    .tint(.white)
                    .controlSize(.regular)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle)
                }
                
                Spacer()
            }
            .padding(.leading, 20)
        }
    }

}

struct HitsMedoDelirioBannerView_Previews: PreviewProvider {

    static var previews: some View {
        HitsMedoDelirioBannerView()
    }

}
