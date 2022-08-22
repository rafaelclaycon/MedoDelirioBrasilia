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
                        Picker(selection: $viewModel.selectedSocialNetwork, label: Text("Rede social")) {
                            Text("Twitter").tag(0)
                            Text("Instagram ou TikTok").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 25)
                        .padding(.bottom, 10)
                        .onChange(of: viewModel.selectedSocialNetwork) { newValue in
                            if newValue == VideoExportType.twitter.rawValue {
                                self.image = VideoMaker.textToImage(drawText: contentTitle.uppercased(), inImage: UIImage(named: "square_video_background")!, atPoint: CGPoint(x: 80, y: 300))
                            } else {
                                self.image = VideoMaker.textToImage(drawText: contentTitle.uppercased(), inImage: UIImage(named: "9_16_video_background")!, atPoint: CGPoint(x: 80, y: 600))
                            }
                        }
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 350)
                        
                        TwitterReplyTipView()
                            .padding(.horizontal)
                            .padding(.vertical)
                        
                        Button {
                            viewModel.createVideo(audioFilename: audioFilename, image: image, contentTitle: contentTitle)
                        } label: {
                            HStack(spacing: 15) {
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
                            .padding(.horizontal, 50)
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
    }

}

struct ShareAsVideoView_Previews: PreviewProvider {

    static var previews: some View {
        ShareAsVideoView(isBeingShown: .constant(true), resultPath: .constant(.empty), image: UIImage(named: "video_background")!, audioFilename: "", contentTitle: "Test")
    }

}
