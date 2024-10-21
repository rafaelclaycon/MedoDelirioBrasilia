//
//  ShareAsVideoView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 22/02/23.
//

import SwiftUI

struct ShareAsVideoView: View {
    
    @StateObject var viewModel: ShareAsVideoViewViewModel
    
    @Binding var isBeingShown: Bool
    @Binding var result: ShareAsVideoResult
    
    @State var useLongerGeneratingVideoMessage: Bool
    @State var didCloseTip: Bool = false
    @State var showTextSocialNetworkTip: Bool = true
    @State var showInstagramTip: Bool = true
    @State private var tipText: String = .empty
    @State private var verticalOffset: CGFloat = 0.0
    @State private var isExpanded = false
    @State private var titleSize = 28.0
    
    @ScaledMetric var vstackSpacing: CGFloat = 22
    @ScaledMetric var bottomPadding: CGFloat = 26
    
    private let textSocialNetworkTip = "Para responder a uma publicação na sua rede social favorita, escolha Salvar Vídeo e depois adicione o vídeo à resposta a partir do app da rede."
    private let instagramTip = "Para fazer um Story, escolha Salvar Vídeo e depois adicione o vídeo ao seu Story a partir do Instagram."

    private var isSquare: Bool {
        viewModel.selectedSocialNetwork == IntendedVideoDestination.twitter.rawValue
    }

    private var is9By16: Bool {
        !isSquare
    }
    
    var body: some View {
        let squareImage = squareImageView(contentName: viewModel.content.title, contentAuthor: viewModel.subtitle)
        let nineBySixteenImage = nineBySixteenImageView(contentName: viewModel.content.title, contentAuthor: viewModel.subtitle)
        
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(spacing: vstackSpacing) {
                        Picker(selection: $viewModel.selectedSocialNetwork, label: Text("Rede social")) {
                            Text("Quadrado").tag(0)
                            Text("9 : 16").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .disabled(viewModel.isShowingProcessingView)
                        .onChange(of: viewModel.selectedSocialNetwork) { newValue in
                            tipText = newValue == IntendedVideoDestination.twitter.rawValue ? textSocialNetworkTip : instagramTip
                        }
                        
                        if viewModel.selectedSocialNetwork == 0 {
                            squareImage
                        } else {
                            nineBySixteenImage
                        }

                        if isSquare {
                            Stepper("Tamanho do título: \(Int(titleSize))", value: $titleSize, in: 22...38, step: 1)
                        }
                        
                        if is9By16 {
                            Toggle("Incluir aviso Ligue o Som", isOn: $viewModel.includeSoundWarning)
                                .disabled(viewModel.isShowingProcessingView)
                        }
                        
                        DisclosureGroup {
                            Slider(value: $verticalOffset, in: -30...30, step: 1)
                            .padding(.top, 5)
                            
                            HStack {
                                Spacer()
                                
                                Button("REDEFINIR") {
                                    verticalOffset = 0
                                }
                                .miniButton(colored: .gray)
                            }
                        } label: {
                            Label("Ajustar posição vertical do texto", systemImage: "arrow.up.and.down")
                                .foregroundColor(.primary)
                        }
                        .disabled(viewModel.isShowingProcessingView)
                        
                        if viewModel.selectedSocialNetwork == IntendedVideoDestination.twitter.rawValue && showTextSocialNetworkTip {
                            TipView(text: $tipText, didTapClose: $didCloseTip)
                                .disabled(viewModel.isShowingProcessingView)
                        } else if viewModel.selectedSocialNetwork == IntendedVideoDestination.instagramTikTok.rawValue && showInstagramTip {
                            TipView(text: $tipText, didTapClose: $didCloseTip)
                                .disabled(viewModel.isShowingProcessingView)
                        }
                        
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            VStack(spacing: vstackSpacing) {
                                if viewModel.selectedSocialNetwork == 0 {
                                    shareButton(view: squareImage)
                                    saveVideoButton(view: squareImage)
                                } else {
                                    shareButton(view: nineBySixteenImage)
                                    saveVideoButton(view: nineBySixteenImage)
                                }
                            }
                        } else {
                            HStack(spacing: 20) {
                                if viewModel.selectedSocialNetwork == 0 {
                                    shareButton(view: squareImage)
                                    saveVideoButton(view: squareImage)
                                } else {
                                    shareButton(view: nineBySixteenImage)
                                    saveVideoButton(view: nineBySixteenImage)
                                }
                            }
                        }
                    }
                    .navigationTitle("Gerar Vídeo")
                    .navigationBarTitleDisplayMode(.inline)
                    .padding(.horizontal, 25)
                    .padding(.bottom, bottomPadding)
                    .navigationBarItems(leading:
                        Button("Cancelar") {
                            self.isBeingShown = false
                        }
                    )
                    .alert(isPresented: $viewModel.showAlert) {
                        Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                    }
                    .onChange(of: viewModel.shouldCloseView) { shouldCloseView in
                        if shouldCloseView {
                            result.videoFilepath = viewModel.pathToVideoFile
                            result.contentId = viewModel.content.id
                            isBeingShown = false
                        }
                    }
                    .onChange(of: didCloseTip) { didCloseTip in
                        if didCloseTip {
                            if viewModel.selectedSocialNetwork == IntendedVideoDestination.twitter.rawValue {
                                showTextSocialNetworkTip = false
                                AppPersistentMemory.setHasHiddenShareAsVideoTextSocialNetworkTip(to: true)
                                self.didCloseTip = false
                            } else if viewModel.selectedSocialNetwork == IntendedVideoDestination.instagramTikTok.rawValue {
                                showInstagramTip = false
                                AppPersistentMemory.setHasHiddenShareAsVideoInstagramTip(to: true)
                                self.didCloseTip = false
                            }
                        }
                    }
                }
            }
            
            if viewModel.isShowingProcessingView {
                if useLongerGeneratingVideoMessage {
                    ProcessingView(message: Shared.ShareAsVideo.generatingVideoLongMessage, progressViewYOffset: -27, progressViewWidth: 270, messageYOffset: 30)
                        .padding(.bottom)
                } else {
                    ProcessingView(message: Shared.ShareAsVideo.generatingVideoShortMessage)
                        .padding(.bottom)
                }
            }
        }
        .onAppear {
            tipText = textSocialNetworkTip
            
            // Cleaning this string is needed in case the user decides do re-export the same sound
            result.videoFilepath = .empty
            result.contentId = .empty
            
            showTextSocialNetworkTip = AppPersistentMemory.getHasHiddenShareAsVideoTextSocialNetworkTip() == false
            showInstagramTip = AppPersistentMemory.getHasHiddenShareAsVideoInstagramTip() == false
        }
    }
    
    private func squareImageView(contentName: String, contentAuthor: String) -> some View {
        ZStack {
            Image("square_video_background")
                .resizable()
                .frame(width: 350, height: 350)
            
            HStack {
                VStack(alignment: .leading, spacing: 15) {
                    Text(contentName)
                        .font(.system(size: titleSize))
                        .bold()
                        .foregroundColor(.black)

                    if !contentAuthor.isEmpty {
                        Text(contentAuthor)
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
                Spacer()
            }
            .padding(.leading, 25)
            .padding(.trailing)
            .padding(.bottom)
            .offset(y: verticalOffset)
        }
        .frame(width: 350, height: 350)
    }
    
    private func nineBySixteenImageView(contentName: String, contentAuthor: String) -> some View {
        ZStack {
            Image(viewModel.includeSoundWarning ? "9_16_video_background_with_warning" : "9_16_video_background_no_warning")
                .resizable()
                .scaledToFit()
                .frame(height: 350)
            
            HStack {
                VStack(alignment: .leading, spacing: 7) {
                    Text(contentName)
                        .font(Font.system(size: 14))
                        .bold()
                        .foregroundColor(.black)

                    if !contentAuthor.isEmpty {
                        Text(contentAuthor)
                            .font(Font.system(size: 12))
                            .foregroundColor(.black)
                    }
                }
                Spacer()
            }
            .padding(.leading, 12)
            .padding(.trailing)
            .padding(.bottom)
            .offset(y: verticalOffset)
        }
        .frame(width: 196, height: 350)
    }
    
    @ViewBuilder func shareButton(view: some View) -> some View {
        Button {
            let renderer = ImageRenderer(content: view)
            renderer.scale = viewModel.selectedSocialNetwork == 0 ? 3.0 : 4.0
            if let image = renderer.uiImage {
                viewModel.generateVideo(withImage: image) { videoPath, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            viewModel.isShowingProcessingView = false
                            viewModel.showOtherError(errorTitle: "Falha na Geração do Vídeo",
                                                     errorBody: error.localizedDescription)
                        }
                        return
                    }
                    guard let videoPath = videoPath else { return }
                    DispatchQueue.main.async {
                        viewModel.isShowingProcessingView = false
                        viewModel.pathToVideoFile = videoPath
                        result.exportMethod = .shareSheet
                        viewModel.shouldCloseView = true
                    }
                }
            }
        } label: {
            HStack(spacing: 15) {
                Spacer()
                
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 25)
                
                Text("Compartilhar")
                    .font(.headline)
                
                Spacer()
            }
        }
        .borderedButton(colored: .accentColor)
        .disabled(viewModel.isShowingProcessingView)
    }
    
    @ViewBuilder func saveVideoButton(view: some View) -> some View {
        Button {
            let renderer = ImageRenderer(content: view)
            renderer.scale = viewModel.selectedSocialNetwork == 0 ? 3.0 : 4.0
            if let image = renderer.uiImage {
                viewModel.saveVideoToPhotos(withImage: image) { success, videoPath in
                    if success {
                        DispatchQueue.main.async {
                            viewModel.pathToVideoFile = videoPath ?? .empty
                            result.exportMethod = .saveAsVideo
                            viewModel.shouldCloseView = true
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 15) {
                Spacer()
                
                Image(systemName: "square.and.arrow.down")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 25)
                
                Text("Salvar Vídeo")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
        }
        .borderedProminentButton(colored: .accentColor)
        .disabled(viewModel.isShowingProcessingView)
    }
    
}

struct ShareAsVideoNewView_Previews: PreviewProvider {
    static var previews: some View {
        ShareAsVideoView(
            viewModel: ShareAsVideoViewViewModel(content: Sound(title: "Você é maluco ou você é idiota, companheiro?"), subtitle: "Lula (Cristiano Botafogo)"),
            isBeingShown: .constant(true),
            result: .constant(ShareAsVideoResult()),
            useLongerGeneratingVideoMessage: false
        )
    }
    
}
