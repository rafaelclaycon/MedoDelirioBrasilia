//
//  SoundListView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/24.
//

import SwiftUI

struct SoundListView: View {

    @StateObject var viewModel: SoundListViewModel<Sound>
    @Binding var currentSoundsListMode: SoundsListMode

    @State private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]

    // MARK: - Computed Properties

    private var searchResults: [Sound] {
        switch viewModel.state {
        case .loaded(let sounds):
            if viewModel.searchText.isEmpty {
                return sounds
            } else {
                return sounds.filter { sound in
                    let searchString = "\(sound.description.lowercased().withoutDiacritics()) \(sound.authorName?.lowercased().withoutDiacritics() ?? "")"
                    return searchString.contains(viewModel.searchText.lowercased().withoutDiacritics())
                }
            }
        case .loading, .error:
            return []
        }
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            switch viewModel.state {
            case .loading:
                VStack {
                    HStack(spacing: 10) {
                        ProgressView()

                        Text("Carregando sons...")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
            case .loaded(let sounds):
                if sounds.isEmpty {
                    VStack {
                        HStack(spacing: 10) {
                            ProgressView()

                            Text("Nenhum som a ser exibido.")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                } else {
                    ScrollView {
                        ScrollViewReader { proxy in
                            // TODO: Insert banners here.

                            LazyVGrid(columns: columns, spacing: UIDevice.isiPhone ? 14 : 20) {
                                if searchResults.isEmpty {
                                    NoSearchResultsView(searchText: $viewModel.searchText)
                                } else {
                                    ForEach(searchResults) { sound in
                                        // Text(sound.title)
                                        SoundCell(
                                            sound: sound,
                                            favorites: $viewModel.favoritesKeeper,
                                            highlighted: $viewModel.highlightKeeper,
                                            nowPlaying: $viewModel.nowPlayingKeeper,
                                            selectedItems: $viewModel.selectionKeeper,
                                            currentSoundsListMode: $currentSoundsListMode
                                        )
                                        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                                        .padding(.horizontal, UIDevice.isiPhone ? 0 : 5)
                                        .onTapGesture {
                                            if currentSoundsListMode == .regular {
                                                if viewModel.nowPlayingKeeper.contains(sound.id) {
                                                    AudioPlayer.shared?.togglePlay()
                                                    viewModel.nowPlayingKeeper.removeAll()
                                                } else {
                                                    //viewModel.play(sound)
                                                }
                                            } else {
                                                if viewModel.selectionKeeper.contains(sound.id) {
                                                    viewModel.selectionKeeper.remove(sound.id)
                                                } else {
                                                    viewModel.selectionKeeper.insert(sound.id)
                                                }
                                            }
                                        }
//                                        .contextMenu {
//                                            if currentSoundsListMode != .selection {
//
//                                            }
//                                        }
                                    }
                                }
                            }
                            .searchable(text: $viewModel.searchText)
                            .disableAutocorrection(true)
                            .padding(.horizontal)
                            .padding(.top, 7)
//                            .onChange(of: geometry.size.width) { newWidth in
//                                self.listWidth = newWidth
//                                columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)
//                            }
//                            .onChange(of: searchResults) { searchResults in
//                                if searchResults.isEmpty {
//                                    columns = [GridItem(.flexible())]
//                                } else {
//                                    columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)
//                                }
//                            }
//                            .onChange(of: soundIdToGoTo) {
//                                if !$0.isEmpty {
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
//                                        withAnimation {
//                                            proxy.scrollTo(soundIdToGoTo, anchor: .center)
//                                        }
//                                        TapticFeedback.warning()
//                                    }
//                                }
//                            }
                        }

//                        if UserSettings.getShowExplicitContent() == false, viewModel.currentViewMode != .favorites {
//                            ExplicitDisabledWarning(
//                                text: UIDevice.isiPhone ? Shared.contentFilterMessageForSoundsiPhone : Shared.contentFilterMessageForSoundsiPadMac
//                            )
//                            .padding(.top, explicitOffWarningTopPadding)
//                            .padding(.horizontal, explicitOffWarningBottomPadding)
//                        }
//
//                        if viewModel.searchText.isEmpty, viewModel.currentViewMode != .favorites {
//                            Text("\(viewModel.sounds.count) SONS")
//                                .font(.footnote)
//                                .foregroundColor(.gray)
//                                .multilineTextAlignment(.center)
//                                .padding(.top, soundCountTopPadding)
//                                .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? soundCountPhoneBottomPadding : soundCountPadBottomPadding)
//                        }
                    }
//                    .if(isAllowedToRefresh) {
//                        $0.refreshable {
//                            Task { // Keep this Task to avoid "cancelled" issue.
//                                await viewModel.sync(lastAttempt: AppPersistentMemory.getLastUpdateAttempt())
//                            }
//                        }
//                    }
                }
            case .error:
                VStack {
                    HStack(spacing: 10) {
                        ProgressView()

                        Text("Erro ao carregar sons.")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(width: geometry.size.width)
                .frame(minHeight: geometry.size.height)
            }
        }
    }
}

//#Preview {
//    SoundListView(
//        viewModel: .init(
//            soundsPublisher: .
//            options: [ContextMenuOption.shareSound]
//        ),
//        currentSoundsListMode: .constant(.regular)
//    )
//}
