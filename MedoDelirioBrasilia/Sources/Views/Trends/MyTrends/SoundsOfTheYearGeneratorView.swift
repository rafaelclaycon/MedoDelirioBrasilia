//
//  SoundsOfTheYearGeneratorView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 08/10/23.
//

import SwiftUI

struct SoundsOfTheYearGeneratorView: View {

    @StateObject var viewModel: SoundsOfTheYearViewViewModel

    @Binding var isBeingShown: Bool

    @ScaledMetric var vstackSpacing: CGFloat = 22
    @ScaledMetric var bottomPadding: CGFloat = 26

    var body: some View {
        let squareImage = squareImageView()
//        let nineBySixteenImage = nineBySixteenImageView(contentName: viewModel.content.title, contentAuthor: viewModel.subtitle)

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

//                        if viewModel.selectedSocialNetwork == 0 {
                        squareImage
//                        } else {
//                            nineBySixteenImage
//                        }

                        if UIDevice.current.userInterfaceIdiom == .phone {
                            VStack(spacing: vstackSpacing) {
                                if viewModel.selectedSocialNetwork == 0 {
                                    shareButton(view: squareImage)
                                    savePhotoButton(view: squareImage)
//                                } else {
//                                    shareButton(view: nineBySixteenImage)
//                                    saveVideoButton(view: nineBySixteenImage)
                                }
                            }
                        } else {
                            HStack(spacing: 20) {
                                if viewModel.selectedSocialNetwork == 0 {
                                    shareButton(view: squareImage)
                                    savePhotoButton(view: squareImage)
//                                } else {
//                                    shareButton(view: nineBySixteenImage)
//                                    saveVideoButton(view: nineBySixteenImage)
                                }
                            }
                        }
                    }
                    .navigationTitle("Gerar Imagem")
                    .navigationBarTitleDisplayMode(.inline)
                    .padding(.horizontal, 25)
                    .padding(.bottom, bottomPadding)
                    .navigationBarItems(leading:
                        Button("Cancelar") {
                            self.isBeingShown = false
                        }
                    )
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
                }
            }

//            if viewModel.isShowingProcessingView {
//                if useLongerGeneratingVideoMessage {
//                    ProcessingView(message: Shared.ShareAsVideo.generatingVideoLongMessage, progressViewYOffset: -27, progressViewWidth: 270, messageYOffset: 30)
//                        .padding(.bottom)
//                } else {
//                    ProcessingView(message: Shared.ShareAsVideo.generatingVideoShortMessage)
//                        .padding(.bottom)
//                }
//            }
        }
        .onAppear {
            viewModel.retrieveTopFive()

            // Cleaning this string is needed in case the user decides do re-export the same sound
//            result.videoFilepath = .empty
//            result.contentId = .empty
        }
    }

    private func squareImageView() -> some View {
        ZStack {
            Image("sounds_of_the_year_background_square")
                .resizable()
                .frame(width: 350, height: 350)

            HStack {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(viewModel.topFive) { item in
                        HStack {
                            Text("#\(item.rankNumber)")
                                .font(.system(size: 24))
                                .bold()
                                .foregroundColor(.white)
                                .opacity(0.7)

                            Text(item.contentName)
                                .font(.body)
                                .bold()
                                .foregroundColor(.black)
                                .lineLimit(2)
                        }
                    }
                }
                //Spacer()
            }
            .padding(.top, 24)
            .padding(.leading, 24)
            .padding(.trailing)
            //.padding(.bottom)
        }
        .frame(width: 350, height: 350)
    }

    @ViewBuilder
    func shareButton(view: some View) -> some View {
        Button {
            // Code
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
        //.disabled(viewModel.isShowingProcessingView)
    }

    @ViewBuilder
    func savePhotoButton(view: some View) -> some View {
        Button {
            // Code
        } label: {
            HStack(spacing: 15) {
                Spacer()

                Image(systemName: "square.and.arrow.down")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 25)

                Text("Salvar Imagem")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()
            }
        }
        .borderedProminentButton(colored: .accentColor)
        //.disabled(viewModel.isShowingProcessingView)
    }
}

#Preview {
    SoundsOfTheYearGeneratorView(
        viewModel: .init(),
        isBeingShown: .constant(true)
    )
}
