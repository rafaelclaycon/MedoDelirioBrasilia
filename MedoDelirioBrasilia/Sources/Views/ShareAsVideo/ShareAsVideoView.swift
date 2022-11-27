//
//  ShareAsVideoView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 21/08/22.
//

import SwiftUI

struct ShareAsVideoView: View {

    @StateObject var viewModel: ShareAsVideoViewViewModel
    @Binding var isBeingShown: Bool
    @Binding var result: ShareAsVideoResult
    @State var useLongerGeneratingVideoMessage: Bool
    @State var didCloseTip: Bool = false
    @State var showTwitterTip: Bool = true
    @State var showInstagramTip: Bool = true
    
    @State private var tipText: String = .empty
    
    private let twitterTip = "Para responder a um tuíte, escolha Salvar Vídeo e depois adicione o vídeo ao seu tuíte a partir do app do Twitter."
    private let instagramTip = "Para fazer um Story, escolha Salvar Vídeo e depois adicione o vídeo ao seu Story a partir do Instagram."
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack {
                        Picker(selection: $viewModel.selectedSocialNetwork, label: Text("Rede social")) {
                            Text("Twitter / Koo").tag(0)
                            Text("Instagram / TikTok").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 25)
                        .padding(.bottom, 10)
                        .disabled(viewModel.isShowingProcessingView)
                        .onChange(of: viewModel.selectedSocialNetwork) { newValue in
                            tipText = newValue == IntendedVideoDestination.twitter.rawValue ? twitterTip : instagramTip
                            viewModel.reloadImage()
                        }
                        
                        Image(uiImage: viewModel.image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 350)
                        
                        if viewModel.selectedSocialNetwork == IntendedVideoDestination.instagramTikTok.rawValue {
                            Toggle("Incluir aviso Ligue o Som", isOn: $viewModel.includeSoundWarning)
                                .onChange(of: viewModel.includeSoundWarning) { _ in
                                    viewModel.reloadImage()
                                }
                                .padding(.horizontal, 25)
                                .padding(.top)
                                .disabled(viewModel.isShowingProcessingView)
                        }
                        
                        if viewModel.selectedSocialNetwork == IntendedVideoDestination.twitter.rawValue && showTwitterTip {
                            TipView(text: $tipText, didTapClose: $didCloseTip)
                                .padding(.horizontal)
                                .padding(.top)
                                .disabled(viewModel.isShowingProcessingView)
                        } else if viewModel.selectedSocialNetwork == IntendedVideoDestination.instagramTikTok.rawValue && showInstagramTip {
                            TipView(text: $tipText, didTapClose: $didCloseTip)
                                .padding(.horizontal)
                                .padding(.top)
                                .disabled(viewModel.isShowingProcessingView)
                        }
                        
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            HStack(spacing: 10) {
                                getShareButton()
                                getShareAsVideoButton()
                            }
                            .padding(.vertical)
                        } else {
                            HStack(spacing: 20) {
                                getShareButton(withWidth: 40)
                                getShareAsVideoButton(withWidth: 40)
                            }
                            .padding(.vertical, 20)
                        }
                    }
                    .navigationTitle("Gerar Vídeo")
                    //.navigationBarTitleDisplayMode(.inline)
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
                            result.contentId = viewModel.contentId
                            isBeingShown = false
                        }
                    }
                    .onChange(of: didCloseTip) { didCloseTip in
                        if didCloseTip {
                            if viewModel.selectedSocialNetwork == IntendedVideoDestination.twitter.rawValue {
                                showTwitterTip = false
                                AppPersistentMemory.setHasHiddenShareAsVideoTwitterTip(to: true)
                            } else if viewModel.selectedSocialNetwork == IntendedVideoDestination.instagramTikTok.rawValue {
                                showInstagramTip = false
                                AppPersistentMemory.setHasHiddenShareAsVideoInstagramTip(to: true)
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
            tipText = twitterTip
            
            // Cleaning this string is needed in case the user decides do re-export the same sound
            result.videoFilepath = .empty
            result.contentId = .empty
            
            showTwitterTip = AppPersistentMemory.getHasHiddenShareAsVideoTwitterTip() == false
            showInstagramTip = AppPersistentMemory.getHasHiddenShareAsVideoInstagramTip() == false
        }
    }
    
    @ViewBuilder func getShareButton(withWidth buttonInternalPadding: CGFloat = 0) -> some View {
        Button {
            viewModel.generateVideo { videoPath, error in
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
        } label: {
            HStack(spacing: 15) {
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 25)
                
                Text("Compartilhar")
                    .font(.headline)
            }
            .padding(.horizontal, buttonInternalPadding)
        }
        .tint(.accentColor)
        //.controlSize(.large)
        .buttonStyle(.bordered)
        //.buttonBorderShape(.capsule)
        .disabled(viewModel.isShowingProcessingView)
    }
    
    @ViewBuilder func getShareAsVideoButton(withWidth buttonInternalPadding: CGFloat = 0) -> some View {
        Button {
            viewModel.saveVideoToPhotos() { success, videoPath in
                if success {
                    DispatchQueue.main.async {
                        viewModel.pathToVideoFile = videoPath ?? .empty
                        result.exportMethod = .saveAsVideo
                        viewModel.shouldCloseView = true
                    }
                }
            }
        } label: {
            HStack(spacing: 15) {
                Image(systemName: "square.and.arrow.down")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 25)
                
                Text("Salvar Vídeo")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, buttonInternalPadding)
        }
        .tint(.accentColor)
        //.controlSize(.large)
        .buttonStyle(.borderedProminent)
        //.buttonBorderShape(.capsule)
        .disabled(viewModel.isShowingProcessingView)
    }

}

struct ShareAsVideoView_Previews: PreviewProvider {

    static var previews: some View {
        ShareAsVideoView(viewModel: ShareAsVideoViewViewModel(contentId: "ABC", contentTitle: "Test", audioFilename: .empty), isBeingShown: .constant(true), result: .constant(ShareAsVideoResult()), useLongerGeneratingVideoMessage: false)
    }

}
