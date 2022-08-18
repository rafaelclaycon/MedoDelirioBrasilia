import SwiftUI

struct ShareAsVideoView: View {

    @Binding var isBeingShown: Bool
    @State var image: UIImage
    @State var audioFilename: String
    @StateObject private var viewModel = ShareAsVideoViewViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 350, height: 350)
                
                Text("Para compartilhar o conteúdo em redes como o Twitter, TikTok e Instagram, é necessário transformá-lo em um vídeo.\n\nToque em Criar Vídeo abaixo. As opções de compartilhamento serão exibidas assim que a geração do vídeo for concluída.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button {
                    viewModel.createVideo(audioFilename: audioFilename)
                } label: {
                    Text("Gerar Vídeo")
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 50)
                }
                .tint(.accentColor)
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .padding(.top)
            }
            .navigationTitle("Compartilhar como Vídeo")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                Button("Cancelar") {
                    self.isBeingShown = false
                }
            )
//            .alert(isPresented: $viewModel.showAlert) {
//                Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
//            }
        }
    }

}

struct ShareAsVideoView_Previews: PreviewProvider {

    static var previews: some View {
        ShareAsVideoView(isBeingShown: .constant(true), image: UIImage(named: "video_background")!, audioFilename: "")
    }

}
