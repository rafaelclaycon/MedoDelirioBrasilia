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
    @Binding var analyticsString: String

    @Environment(\.colorScheme) var colorScheme

    @ScaledMetric var vstackSpacing: CGFloat = 24
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

        ZStack {
            NavigationView {
                ScrollView {
                    VStack(spacing: vstackSpacing) {
                        TabView {
                            rankingSquare
                                .padding(.bottom, 50)

                            countSquare
                                .padding(.bottom, 50)
                        }
                        .frame(width: 350, height: 400)
                        .tabViewStyle(.page)

                        AddHashtagIncentive()
                            .padding(.top, -15)

                        savePhotosButton(
                            firstView: rankingSquare,
                            secondView: countSquare
                        )
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
                    .alert(isPresented: $viewModel.showAlert) {
                        Alert(
                            title: Text(viewModel.alertTitle),
                            message: Text(viewModel.alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }

            if viewModel.isShowingProcessingView {
                ProcessingView(message: "Gerando imagens...")
                    .padding(.bottom)
            }
        }
        .onAppear {
            setUpAppearance()
            viewModel.loadInformation()
        }
        .onChange(of: viewModel.shouldProcessPostExport) { shouldProcess in
            guard shouldProcess else { return }
            if viewModel.exportErrors.isEmpty {
                analyticsString = viewModel.analyticsString()
                isBeingShown.toggle()
            } else {
                viewModel.isShowingProcessingView = false
                viewModel.showExportError()
                viewModel.exportErrors.removeAll()
            }
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
                                //.opacity(0.7)

                            Text(item.contentName)
                                .font(.body)
                                .bold()
                                .foregroundColor(.black)
                                .lineLimit(2)
                        }
                    }
                }
            }
            .padding(.top, 24)
            .padding(.leading, 24)
            .padding(.trailing)
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
    func savePhotosButton(
        firstView: some View,
        secondView: some View
    ) -> some View {
        Button {
            Task {
                let firstRenderer = ImageRenderer(content: firstView)
                firstRenderer.scale = 3.0
                if let firstImage = firstRenderer.uiImage {
                    do {
                        try await viewModel.save(image: firstImage)
                    } catch {
                        viewModel.exportErrors.append("1ª imagem: \(error.localizedDescription)")
                        dump(error)
                    }
                }

                let secondRenderer = ImageRenderer(content: secondView)
                secondRenderer.scale = 3.0
                if let secondImage = secondRenderer.uiImage {
                    do {
                        try await viewModel.save(image: secondImage)
                    } catch {
                        viewModel.exportErrors.append("2ª imagem: \(error.localizedDescription)")
                        dump(error)
                    }
                }

                viewModel.shouldProcessPostExport.toggle()
            }
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
        .disabled(viewModel.isShowingProcessingView)
    }

    func setUpAppearance() {
        if colorScheme != .dark {
            UIPageControl.appearance().currentPageIndicatorTintColor = .black
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
        }
    }
}

extension RetroView {

    struct AddHashtagIncentive: View {

        @State private var showCopiedMessage: Bool = false

        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            VStack(spacing: .zero) {
                VStack(alignment: .leading, spacing: 8) {
                    VStack {
                        Text("Que tal compartilhar as imagens com a hashtag ")
                            .font(.callout) +

                        Text("#MedoEDelírioiOS")
                            .font(.callout)
                            .foregroundColor(.blue)
                            .bold() +

                        Text("?")
                            .font(.callout)
                    }
                    .padding(.leading, 3)

                    HStack {
                        Spacer()

                        Button {
                            UIPasteboard.general.string = "#MedoEDelírioiOS"

                            showCopiedMessage = true
                            TapticFeedback.success()

                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showCopiedMessage = false
                            }
                        } label: {
                            if showCopiedMessage {
                                Label("Copiada!", systemImage: "checkmark")
                            } else {
                                Label("Copiar hashtag", systemImage: "doc.on.doc")
                            }
                        }
                        .tint(.primary)
                        .controlSize(.regular)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle)
                        .opacity(colorScheme == .dark ? 1.0 : 0.6)
                    }
                    .padding(.top, 5)
                }
                .padding()
            }
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.gray)
                    .opacity(colorScheme == .dark ? 0.3 : 0.15)
            }
        }
    }
}

#Preview {
    RetroView(
        viewModel: .init(),
        isBeingShown: .constant(true),
        analyticsString: .constant("")
    )
}
