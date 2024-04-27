//
//  SoundList.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/24.
//

import SwiftUI

struct SoundList: View {

    // MARK: - Dependencies

    @StateObject var viewModel: SoundListViewModel<Sound>
    @Binding var currentSoundsListMode: SoundsListMode
    let emptyStateView: AnyView
    var headerView: AnyView? = .empty

    // MARK: - Stored Properties

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
                        emptyStateView
                    }
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                } else {
                    ScrollView {
                        ScrollViewReader { proxy in
                            // TODO: Insert banners here.
                            if let headerView {
                                headerView
                            }

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
                                                    viewModel.play(sound)
                                                }
                                            } else {
                                                if viewModel.selectionKeeper.contains(sound.id) {
                                                    viewModel.selectionKeeper.remove(sound.id)
                                                } else {
                                                    viewModel.selectionKeeper.insert(sound.id)
                                                }
                                            }
                                        }
                                        .contextMenu {
                                            if currentSoundsListMode != .selection {
                                                ForEach(viewModel.menuOptions, id: \.title) { section in
                                                    Section {
                                                        ForEach(section.options(sound)) { option in
                                                            Button {
                                                                option.action(sound, viewModel)
                                                            } label: {
                                                                Label(
                                                                    option.title(viewModel.favoritesKeeper.contains(sound.id)),
                                                                    systemImage: option.symbol(viewModel.favoritesKeeper.contains(sound.id))
                                                                )
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .searchable(text: $viewModel.searchText)
                            .disableAutocorrection(true)
                            .padding(.horizontal)
                            .padding(.top, 7)
                            .sheet(isPresented: $viewModel.showingModalView) {
                                switch viewModel.subviewToOpen {
                                case .shareAsVideo:
                                    ShareAsVideoView(
                                        viewModel: .init(content: viewModel.selectedSound!, subtitle: viewModel.selectedSound?.authorName ?? .empty),
                                        isBeingShown: $viewModel.showingModalView,
                                        result: $viewModel.shareAsVideoResult,
                                        useLongerGeneratingVideoMessage: false
                                    )

                                case .addToFolder:
                                    AddToFolderView(
                                        isBeingShown: $viewModel.showingModalView,
                                        hadSuccess: $viewModel.hadSuccessAddingToFolder,
                                        folderName: $viewModel.folderName,
                                        pluralization: $viewModel.pluralization,
                                        selectedSounds: viewModel.selectedSounds!
                                    )

                                case .soundDetail:
                                    SoundDetailView(
                                        isBeingShown: $viewModel.showingModalView,
                                        sound: viewModel.selectedSound ?? Sound(title: "")
                                    )
                                }
                            }
                            .alert(isPresented: $viewModel.showAlert) {
                                switch viewModel.alertType {
                                case .singleOption, .twoOptionsOneDelete:
                                    return Alert(
                                        title: Text(viewModel.alertTitle),
                                        message: Text(viewModel.alertMessage),
                                        dismissButton: .default(Text("OK"))
                                    )

                                case .twoOptions:
                                    return Alert(
                                        title: Text(viewModel.alertTitle),
                                        message: Text(viewModel.alertMessage),
                                        primaryButton: .default(
                                            Text("Relatar Problema por E-mail"),
                                            action: {
                                                // viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog = true
                                            }
                                        ),
                                        secondaryButton: .cancel(Text("Fechar"))
                                    )

                                case .twoOptionsOneRedownload:
                                    return Alert(
                                        title: Text(viewModel.alertTitle),
                                        message: Text(viewModel.alertMessage),
                                        primaryButton: .default(
                                            Text("Baixar Conteúdo Novamente"),
                                            action: {
                                                guard let content = viewModel.selectedSound else { return }
                                                viewModel.redownloadServerContent(withId: content.id)
                                            }), 
                                        secondaryButton: .cancel(Text("Fechar"))
                                    )

                                case .twoOptionsOneContinue:
                                    return Alert(
                                        title: Text(viewModel.alertTitle),
                                        message: Text(viewModel.alertMessage),
                                        primaryButton: .default(
                                            Text("Continuar"),
                                            action: {
                                                AppPersistentMemory.increaseShareManyMessageShowCountByOne()
                                                // viewModel.shareSelected()
                                            }),
                                        secondaryButton: .cancel(Text("Cancelar"))
                                    )
                                }
                            }
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
