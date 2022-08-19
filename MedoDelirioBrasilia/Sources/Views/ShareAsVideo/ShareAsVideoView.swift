import SwiftUI

struct ShareAsVideoView: View {

    @StateObject private var viewModel = ShareAsVideoViewViewModel()
    @Binding var isBeingShown: Bool
    @State var image: UIImage
    @State var audioFilename: String
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack {
                        Text("Esse será o fundo do vídeo:")
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 350, height: 350)
                        
                        Text("Compartilhe o conteúdo em redes como o Twitter, TikTok e Instagram transformando-o em um vídeo.")
                            .multilineTextAlignment(.center)
                            .padding(.all, 20)
                        
                        Button {
                            viewModel.createVideo(audioFilename: audioFilename, image: image)
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
                        .padding(.bottom)
                        .background(SharingViewController(isPresenting: $viewModel.isPresentingShareSheet) {
                            let url = URL(fileURLWithPath: viewModel.pathToVideoFile)
                            let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                              
                            // For iPad
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                av.popoverPresentationController?.sourceView = UIView()
                            }

                            av.completionWithItemsHandler = { _, _, _, _ in
                                viewModel.isPresentingShareSheet = false // required to prevent it from auto re-opening
                                isBeingShown = false
                            }
                            return av
                        })
                    }
                    .navigationTitle("Compartilhar como Vídeo")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(leading:
                        Button("Cancelar") {
                            self.isBeingShown = false
                        }
                    )
                    .alert(isPresented: $viewModel.showAlert) {
                        Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                    }
                }
            }
            
            if viewModel.isShowingProcessingView {
                ProcessingView(message: $viewModel.processingViewMessage)
                    .padding(.bottom)
            }
        }
    }

}

struct ShareAsVideoView_Previews: PreviewProvider {

    static var previews: some View {
        ShareAsVideoView(isBeingShown: .constant(true), image: UIImage(named: "video_background")!, audioFilename: "")
    }

}
