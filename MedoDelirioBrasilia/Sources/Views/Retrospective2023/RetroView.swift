//
//  SoundsOfTheYearGeneratorView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 08/10/23.
//

import SwiftUI

struct RetroView: View {

    @StateObject var viewModel: ViewModel

    @Binding var isBeingShown: Bool

    @Environment(\.colorScheme) var colorScheme

    @ScaledMetric var vstackSpacing: CGFloat = 22
    @ScaledMetric var bottomPadding: CGFloat = 26

    var mostCommonDayFont: Font {
        if viewModel.mostCommonShareDay.count <= 7 {
            return .system(size: 50, weight: .bold)
        } else if viewModel.mostCommonShareDay.count <= 13 {
            return .system(size: 40, weight: .bold)
        } else {
            return .system(size: 30, weight: .bold)
        }
    }

    var mostCommonDaySubtitle: String {
        viewModel.mostCommonShareDayPluralization == .plural ? "dias que mais compartilha" : "dia que mais compartilha"
    }

    var body: some View {
        let rankingSquare = topFiveSquareImageView()
        let countSquare = shareCountAndDaySquareImageView()
//        let nineBySixteenImage = nineBySixteenImageView(contentName: viewModel.content.title, contentAuthor: viewModel.subtitle)

        ZStack {
            NavigationView {
                ScrollView {
                    VStack(spacing: vstackSpacing) {
//                        Picker(selection: $viewModel.selectedSocialNetwork, label: Text("Rede social")) {
//                            Text("Quadrado").tag(0)
//                            Text("9 : 16").tag(1)
//                        }
//                        .pickerStyle(SegmentedPickerStyle())
//                        .disabled(viewModel.isShowingProcessingView)

//                        if viewModel.selectedSocialNetwork == 0 {
                        TabView {
                            rankingSquare
                                .padding(.bottom, 50)

                            countSquare
                                .padding(.bottom, 50)
                        }
                        .frame(width: 350, height: 400)
                        .tabViewStyle(.page)
//                        } else {
//                            nineBySixteenImage
//                        }

                        if UIDevice.current.userInterfaceIdiom == .phone {
                            VStack(spacing: vstackSpacing) {
                                if viewModel.selectedSocialNetwork == 0 {
                                    shareButton(view: rankingSquare)
                                    savePhotoButton(view: rankingSquare)
//                                } else {
//                                    shareButton(view: nineBySixteenImage)
//                                    saveVideoButton(view: nineBySixteenImage)
                                }
                            }
                        } else {
                            HStack(spacing: 20) {
                                if viewModel.selectedSocialNetwork == 0 {
                                    shareButton(view: rankingSquare)
                                    savePhotoButton(view: rankingSquare)
//                                } else {
//                                    shareButton(view: nineBySixteenImage)
//                                    saveVideoButton(view: nineBySixteenImage)
                                }
                            }
                        }
                    }
                    .navigationTitle("Retrospectiva")
                    .navigationBarTitleDisplayMode(.inline)
                    .padding([.horizontal, .top], 25)
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
            setUpAppearance()

            viewModel.retrieveTopFive()
            viewModel.loadShareCount()
            do {
                viewModel.mostCommonShareDay = try viewModel.mostCommonDay(from: LocalDatabase.shared.allDatesInWhichTheUserShared()) ?? "-"
            } catch {
                print(error)
            }

            // Cleaning this string is needed in case the user decides do re-export the same sound
//            result.videoFilepath = .empty
//            result.contentId = .empty
        }
    }

    private func topFiveSquareImageView() -> some View {
        ZStack {
            Image("retro_back_1")
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

    private func shareCountAndDaySquareImageView() -> some View {
        ZStack {
            Image("retro_back_2")
                .resizable()
                .frame(width: 350, height: 350)

            VStack(spacing: 15) {
                VStack(alignment: .center, spacing: -10) {
                    Text("\(viewModel.shareCount)")
                        .font(.system(size: 80, weight: .heavy))
                        .bold()
                        .foregroundColor(.darkestGreen)

                    Text(viewModel.shareCount > 1 ? "compartilhamentos" : "compartilhamento")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                }

                VStack(alignment: .center, spacing: .zero) {
                    Text(viewModel.mostCommonShareDay)
                        .font(mostCommonDayFont)
                        .bold()
                        .foregroundColor(.darkestGreen)
                        .multilineTextAlignment(.center)

                    Text(mostCommonDaySubtitle)
                        .font(.system(size: 25, weight: .bold))
                        .bold()
                        .foregroundColor(.white)
                }
            }
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

                Text("Salvar Imagens")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()
            }
        }
        .borderedProminentButton(colored: .accentColor)
        //.disabled(viewModel.isShowingProcessingView)
    }

    func setUpAppearance() {
        if colorScheme != .dark {
            UIPageControl.appearance().currentPageIndicatorTintColor = .black
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
        }
    }
}

#Preview {
    RetroView(
        viewModel: .init(),
        isBeingShown: .constant(true)
    )
}
