import SwiftUI

struct ShareAsVideoView: View {

    @StateObject private var viewModel = ShareAsVideoViewViewModel()
    @Binding var isBeingShown: Bool
    @Binding var resultPath: String
    @State var image: UIImage
    @State var audioFilename: String
    @State var contentTitle: String
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack {
                        Text("Essa será a imagem do vídeo:")
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 350, height: 350)
                        
                        Text("Compartilhe o conteúdo em redes como o Twitter, TikTok e Instagram transformando-o em um vídeo.\n\nSe possível, inclua a #MedoEDelírioiOS\n\nPara responder um tuíte, use a opção Salvar Vídeo.")
                            .multilineTextAlignment(.center)
                            .padding(.all, 20)
                        
                        Button {
                            viewModel.createVideo(audioFilename: audioFilename, image: image, contentTitle: contentTitle)
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
                        .padding(.bottom)
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
                    .onChange(of: viewModel.presentShareSheet) { shouldPresentShareSheet in
                        if shouldPresentShareSheet {
                            resultPath = viewModel.pathToVideoFile
                            isBeingShown = false
                        }
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
        ShareAsVideoView(isBeingShown: .constant(true), resultPath: .constant(.empty), image: UIImage(named: "video_background")!, audioFilename: "", contentTitle: "Test")
    }

}
