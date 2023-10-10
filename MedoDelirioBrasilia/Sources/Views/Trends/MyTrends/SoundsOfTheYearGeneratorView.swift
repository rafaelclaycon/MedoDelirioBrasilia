//
//  SoundsOfTheYearGeneratorView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 08/10/23.
//

import SwiftUI

struct SoundsOfTheYearGeneratorView: View {

    var body: some View {
        EmptyView()
//        let squareImage = squareImageView(contentName: viewModel.content.title, contentAuthor: viewModel.subtitle)
//        let nineBySixteenImage = nineBySixteenImageView(contentName: viewModel.content.title, contentAuthor: viewModel.subtitle)
//
//        ZStack {
//            NavigationView {
//                ScrollView {
//                    VStack(spacing: vstackSpacing) {
//                        Picker(selection: $viewModel.selectedSocialNetwork, label: Text("Rede social")) {
//                            Text("Quadrado").tag(0)
//                            Text("9 : 16").tag(1)
//                        }
//                        .pickerStyle(SegmentedPickerStyle())
//                        .disabled(viewModel.isShowingProcessingView)
//
//                        if viewModel.selectedSocialNetwork == 0 {
//                            squareImage
//                        } else {
//                            nineBySixteenImage
//                        }
//
//                        if UIDevice.current.userInterfaceIdiom == .phone {
//                            VStack(spacing: vstackSpacing) {
//                                if viewModel.selectedSocialNetwork == 0 {
//                                    shareButton(view: squareImage)
//                                    saveVideoButton(view: squareImage)
//                                } else {
//                                    shareButton(view: nineBySixteenImage)
//                                    saveVideoButton(view: nineBySixteenImage)
//                                }
//                            }
//                        } else {
//                            HStack(spacing: 20) {
//                                if viewModel.selectedSocialNetwork == 0 {
//                                    shareButton(view: squareImage)
//                                    saveVideoButton(view: squareImage)
//                                } else {
//                                    shareButton(view: nineBySixteenImage)
//                                    saveVideoButton(view: nineBySixteenImage)
//                                }
//                            }
//                        }
//                    }
//                    .navigationTitle("Gerar Vídeo")
//                    .navigationBarTitleDisplayMode(.inline)
//                    .padding(.horizontal, 25)
//                    .padding(.bottom, bottomPadding)
//                    .navigationBarItems(leading:
//                        Button("Cancelar") {
//                            self.isBeingShown = false
//                        }
//                    )
//                    .alert(isPresented: $viewModel.showAlert) {
//                        Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
//                    }
//                    .onChange(of: viewModel.shouldCloseView) { shouldCloseView in
//                        if shouldCloseView {
//                            result.videoFilepath = viewModel.pathToVideoFile
//                            result.contentId = viewModel.content.id
//                            isBeingShown = false
//                        }
//                    }
//                    .onChange(of: didCloseTip) { didCloseTip in
//                        if didCloseTip {
//                            if viewModel.selectedSocialNetwork == IntendedVideoDestination.twitter.rawValue {
//                                showTextSocialNetworkTip = false
//                                AppPersistentMemory.setHasHiddenShareAsVideoTextSocialNetworkTip(to: true)
//                                self.didCloseTip = false
//                            } else if viewModel.selectedSocialNetwork == IntendedVideoDestination.instagramTikTok.rawValue {
//                                showInstagramTip = false
//                                AppPersistentMemory.setHasHiddenShareAsVideoInstagramTip(to: true)
//                                self.didCloseTip = false
//                            }
//                        }
//                    }
//                }
//            }
//
//            if viewModel.isShowingProcessingView {
//                if useLongerGeneratingVideoMessage {
//                    ProcessingView(message: Shared.ShareAsVideo.generatingVideoLongMessage, progressViewYOffset: -27, progressViewWidth: 270, messageYOffset: 30)
//                        .padding(.bottom)
//                } else {
//                    ProcessingView(message: Shared.ShareAsVideo.generatingVideoShortMessage)
//                        .padding(.bottom)
//                }
//            }
//        }
//        .onAppear {
//            // Cleaning this string is needed in case the user decides do re-export the same sound
//            result.videoFilepath = .empty
//            result.contentId = .empty
//        }
    }
}

#Preview {
    SoundsOfTheYearGeneratorView()
}
