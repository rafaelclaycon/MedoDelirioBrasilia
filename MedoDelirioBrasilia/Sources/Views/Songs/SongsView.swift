//
//  SongsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 24/05/22.
//

import SwiftUI

struct SongsView: View {

    enum SubviewToOpen {
        case genrePicker, shareAsVideoView
    }
    
    @StateObject private var viewModel = SongsViewViewModel()
    
    @State private var searchText = ""
    @State private var searchBar: UISearchBar?
    @State private var currentGenre: String? = nil

    @State private var subviewToOpen: SubviewToOpen = .genrePicker
    @State private var showingModalView = false
    
    // Share as Video
    @State private var shareAsVideo_Result = ShareAsVideoResult()
    
    @EnvironmentObject var settingsHelper: SettingsHelper

    // Dynamic Type
    @ScaledMetric private var explicitOffWarningTopPadding = 16
    @ScaledMetric private var explicitOffWarningPhoneBottomPadding = 20
    @ScaledMetric private var explicitOffWarningPadBottomPadding = 20
    @ScaledMetric private var songCountTopPadding = 10
    @ScaledMetric private var songCountBottomPadding = 22
    
    private var columns: [GridItem] {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return [
                GridItem(.flexible())
            ]
        } else {
            return [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        }
    }
    
    var searchResults: [Song] {
        if searchText.isEmpty {
            guard let currentGenre else { return viewModel.songs }
            return viewModel.songs.filter({ $0.genreId == currentGenre })
        } else {
            return viewModel.songs.filter { song in
                let searchString = song.title.lowercased().withoutDiacritics()
                return searchString.contains(searchText.lowercased().withoutDiacritics())
            }
        }
    }

    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        if searchResults.isEmpty {
                            NoSearchResultsView(searchText: $searchText)
                                .padding(.vertical, UIScreen.main.bounds.height / 4)
                        } else {
                            ForEach(searchResults) { song in
                                SongCell(song: song, nowPlaying: $viewModel.nowPlayingKeeper)
                                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 5)
                                    .onTapGesture {
                                        if viewModel.nowPlayingKeeper.contains(song.id) {
                                            AudioPlayer.shared?.togglePlay()
                                            viewModel.nowPlayingKeeper.removeAll()
                                        } else {
                                            viewModel.play(song: song)
                                        }
                                    }
                                    .contextMenu(menuItems: {
                                        Section {
                                            Button {
                                                viewModel.share(song: song)
                                            } label: {
                                                Label(Shared.shareSongButtonText, systemImage: "square.and.arrow.up")
                                            }
                                            
                                            Button {
                                                viewModel.selectedSong = song
                                                showingModalView.toggle()
                                            } label: {
                                                Label(Shared.shareAsVideoButtonText, systemImage: "film")
                                            }
                                        }
                                        
                                        Section {
                                            Button {
                                                viewModel.selectedSong = song
                                                viewModel.showEmailAppPicker_suggestChangeConfirmationDialog = true
                                            } label: {
                                                Label("Sugerir Alteração", systemImage: "exclamationmark.bubble")
                                            }
                                        }
                                    })
                            }
                        }
                    }
                    .searchable(text: $searchText)
                    .disableAutocorrection(true)
                    .padding(.horizontal)
                    .padding(.top, 7)
                    
                    if UserSettings.getShowExplicitContent() == false {
                        Text(UIDevice.current.userInterfaceIdiom == .phone ? Shared.contentFilterMessageForSongsiPhone : Shared.contentFilterMessageForSongsiPadMac)
                            .multilineTextAlignment(.center)
                            .padding(.top, explicitOffWarningTopPadding)
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? explicitOffWarningPhoneBottomPadding : explicitOffWarningPadBottomPadding)
                    }
                    
                    if searchText.isEmpty, currentGenre == nil {
                        Text("\(viewModel.songs.count) MÚSICAS.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, songCountTopPadding)
                            .padding(.bottom, songCountBottomPadding)
                    }
                }
            }
            .navigationTitle("Músicas")
            .navigationBarItems(leading:
                getLeadingToolbarControl()
            )
            .toolbar {
                Menu {
                    Section {
                        Picker("Ordenação", selection: $viewModel.sortOption) {
                            Text("Título")
                                .tag(0)
                            
                            Text("Mais Recentes no Topo")
                                .tag(1)
                            
                            Text("Mais Longas no Topo")
                                .tag(2)
                            
                            Text("Mais Curtas no Topo")
                                .tag(3)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
                .onChange(of: viewModel.sortOption) {
                    viewModel.sortSongs(by: SongSortOption(rawValue: $0) ?? .dateAddedDescending)
                    UserSettings.setSongSortOption(to: $0)
                }
                .onChange(of: shareAsVideo_Result.videoFilepath) { videoResultPath in
                    if videoResultPath.isEmpty == false {
                        if shareAsVideo_Result.exportMethod == .saveAsVideo {
                            viewModel.showVideoSavedSuccessfullyToast()
                        } else {
                            viewModel.shareVideo(withPath: videoResultPath, andContentId: shareAsVideo_Result.contentId)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.reloadList()
                viewModel.donateActivity()
            }
            .onDisappear {
                AudioPlayer.shared?.cancel()
                viewModel.nowPlayingKeeper.removeAll()
            }
            .sheet(isPresented: $viewModel.isShowingShareSheet) {
                viewModel.iPadShareSheet
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_suggestChangeConfirmationDialog) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_suggestChangeConfirmationDialog,
                                   didCopySupportAddress: .constant(false),
                                   subject: String(format: Shared.Email.suggestSongChangeSubject, viewModel.selectedSong?.title ?? ""),
                                   emailBody: String(format: Shared.Email.suggestSongChangeBody, viewModel.selectedSong?.id ?? ""))
            }
            .sheet(isPresented: $showingModalView) {
                switch subviewToOpen {
                case .genrePicker:
                    GenrePickerView(selectedId: $currentGenre)

                case .shareAsVideoView:
                    if #available(iOS 16.0, *) {
                        ShareAsVideoView(viewModel: ShareAsVideoViewViewModel(contentId: viewModel.selectedSong?.id ?? .empty, contentTitle: viewModel.selectedSong?.title ?? .empty, contentAuthor: viewModel.selectedSong?.genreName ?? .empty, audioFilename: viewModel.selectedSong?.filename ?? .empty), isBeingShown: $showingModalView, result: $shareAsVideo_Result, useLongerGeneratingVideoMessage: true)
                    } else {
                        ShareAsVideoLegacyView(viewModel: ShareAsVideoLegacyViewViewModel(contentId: viewModel.selectedSong?.id ?? .empty, contentTitle: viewModel.selectedSong?.title ?? .empty, audioFilename: viewModel.selectedSong?.filename ?? .empty), isBeingShown: $showingModalView, result: $shareAsVideo_Result, useLongerGeneratingVideoMessage: true)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_songUnavailableConfirmationDialog) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_songUnavailableConfirmationDialog,
                                   didCopySupportAddress: .constant(false),
                                   subject: Shared.issueSuggestionEmailSubject,
                                   emailBody: Shared.issueSuggestionEmailBody)
            }
            .alert(isPresented: $viewModel.showAlert) {
                switch viewModel.alertType {
                case .singleOption:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                    
                default:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), primaryButton: .default(Text("Relatar Problema por E-mail"), action: {
                        viewModel.showEmailAppPicker_songUnavailableConfirmationDialog = true
                    }), secondaryButton: .cancel(Text("Fechar")))
                }
            }
            .onReceive(settingsHelper.$updateSoundsList) { shouldUpdate in
                if shouldUpdate {
                    viewModel.reloadList()
                    settingsHelper.updateSoundsList = false
                }
            }
            
            if viewModel.displaySharedSuccessfullyToast {
                VStack {
                    Spacer()
                    
                    ToastView(text: viewModel.shareBannerMessage)
                        .padding()
                }
                .transition(.moveAndFade)
            }
        }
    }
    
    @ViewBuilder func getLeadingToolbarControl() -> some View {
        Button {
            subviewToOpen = .genrePicker
            showingModalView.toggle()
        } label: {
            Image(systemName: currentGenre == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
        }
    }
}

struct SongsView_Previews: PreviewProvider {

    static var previews: some View {
        SongsView()
    }

}
