import SwiftUI

struct ShareAsVideoView: View {

    @StateObject var viewModel: ShareAsVideoViewViewModel
    @Binding var isBeingShown: Bool
    @Binding var result: ShareAsVideoResult
    @State private var userSelectedImage: UIImage?
    var hasUserSelectedImage: Bool {
        return userSelectedImage != nil
    }
    
    @State private var tipText: String = .empty
    
    private let twitterTip = "Para responder um tuíte, escolha Salvar Vídeo na tela de compartilhamento. Depois, adicione o vídeo ao seu tuíte a partir do Twitter."
    private let instagramTip = "Para fazer um Story, escolha Salvar Vídeo na tela de compartilhamento. Depois, adicione o vídeo ao seu Story a partir do Instagram."
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack {
                        Picker(selection: $viewModel.selectedSocialNetwork, label: Text("Rede social")) {
                            Text("Twitter").tag(0)
                            Text("Instagram ou TikTok").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 25)
                        .padding(.bottom, 10)
                        .onChange(of: viewModel.selectedSocialNetwork) { selectedSocialNetwork in
                            tipText = selectedSocialNetwork == VideoExportType.twitter.rawValue ? twitterTip : instagramTip
                            viewModel.reloadImage(hasUserSelectedImage: hasUserSelectedImage, userSelectedImage: userSelectedImage)
                        }
                        
                        Image(uiImage: viewModel.image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 350)
                        
                        if viewModel.selectedSocialNetwork == VideoExportType.instagramTikTok.rawValue && hasUserSelectedImage == false {
                            Toggle("Incluir aviso Ligue o Som", isOn: $viewModel.includeSoundWarning)
                                .onChange(of: viewModel.includeSoundWarning) { _ in
                                    viewModel.reloadImage()
                                }
                                .padding(.horizontal, 25)
                                .padding(.top)
                        }
                        
                        NavigationLink(destination: ImagePicker(image: $userSelectedImage)) {
                            Label("Escolher imagem da galeria...", systemImage: "photo.on.rectangle.angled")
                        }
                        .padding(.top)
                        
                        if hasUserSelectedImage {
                            Button {
                                userSelectedImage = nil
                                viewModel.resetImageToDefault()
                            } label: {
                                Label("Remover imagem", systemImage: "x.circle")
                            }
                            .padding(.top)
                        }
                        
                        TipView(text: $tipText)
                            .padding(.horizontal, 25)
                            .padding(.vertical)
                        
                        Button {
                            viewModel.createVideo(hasUserSelectedImage: hasUserSelectedImage)
                        } label: {
                            HStack(spacing: 20) {
                                if viewModel.selectedSocialNetwork == VideoExportType.twitter.rawValue {
                                    Image("twitter")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 25)
                                } else {
                                    HStack(spacing: 10) {
                                        Image("instagram")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 25)
                                        
                                        Image("tiktok")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 25)
                                    }
                                }
                                
                                Text("Compartilhar")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 40)
                        }
                        .tint(.accentColor)
                        .controlSize(.large)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .padding(.bottom)
                    }
                    .navigationTitle("Gerar Vídeo")
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
                            result.videoFilepath = viewModel.pathToVideoFile
                            result.contentId = viewModel.contentId
                            isBeingShown = false
                        }
                    }
                    .onChange(of: userSelectedImage) { userSelectedImage in
                        viewModel.reloadImage(hasUserSelectedImage: hasUserSelectedImage, userSelectedImage: userSelectedImage)
                    }
                }
            }
            
            if viewModel.isShowingProcessingView {
                ProcessingView(message: $viewModel.processingViewMessage)
                    .padding(.bottom)
            }
        }
        .onAppear {
            tipText = twitterTip
            // Cleaning this string is needed in case the user decides do re-export the same sound
            result.videoFilepath = .empty
            result.contentId = .empty
        }
    }

}

struct ShareAsVideoView_Previews: PreviewProvider {

    static var previews: some View {
        ShareAsVideoView(viewModel: ShareAsVideoViewViewModel(contentId: "ABC", contentTitle: "Test", audioFilename: .empty), isBeingShown: .constant(true), result: .constant(ShareAsVideoResult()))
    }

}
