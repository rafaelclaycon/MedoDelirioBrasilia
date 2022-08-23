import SwiftUI

struct ShareAsVideoView: View {

    @StateObject var viewModel: ShareAsVideoViewViewModel
    @Binding var isBeingShown: Bool
    @Binding var resultPath: String
    
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
                        .onChange(of: viewModel.selectedSocialNetwork) { newValue in
                            tipText = newValue == VideoExportType.twitter.rawValue ? twitterTip : instagramTip
                            viewModel.reloadImage()
                        }
                        
                        Image(uiImage: viewModel.image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 350)
                        
                        if viewModel.selectedSocialNetwork == VideoExportType.instagramTikTok.rawValue {
                            Toggle("Incluir aviso Ligue o Som", isOn: $viewModel.includeSoundWarning)
                                .onChange(of: viewModel.includeSoundWarning) { _ in
                                    viewModel.reloadImage()
                                }
                                .padding(.horizontal, 25)
                                .padding(.top)
                        }
                        
                        TipView(text: $tipText)
                            .padding(.horizontal)
                            .padding(.vertical)
                        
                        Button {
                            viewModel.createVideo()
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
        .onAppear {
            tipText = twitterTip
            // Cleaning this string is needed in case the user decides do re-export the same sound
            resultPath = .empty
        }
    }

}

struct ShareAsVideoView_Previews: PreviewProvider {

    static var previews: some View {
        ShareAsVideoView(viewModel: ShareAsVideoViewViewModel(contentTitle: "Test", audioFilename: .empty), isBeingShown: .constant(true), resultPath: .constant(.empty))
    }

}
