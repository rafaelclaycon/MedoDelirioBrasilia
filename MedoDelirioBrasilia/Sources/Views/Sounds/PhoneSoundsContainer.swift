//
//  PhoneSoundsContainer.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/24.
//

import SwiftUI

struct PhoneSoundsContainer: View {

    enum SubviewToOpen {
        case onboardingView, addToFolderView, shareAsVideoView, settingsView, whatsNewView, syncInfoView, soundDetailView, retrospective
    }

    @StateObject var viewModel: PhoneSoundsContainerViewModel
    @Binding var currentSoundsListMode: SoundsListMode

    @State private var favoritesKeeper = Set<String>()
    @State private var highlightKeeper = Set<String>()
    @State private var nowPlayingKeeper = Set<String>()
    @State private var selectionKeeper = Set<String>()

    @State private var subviewToOpen: SubviewToOpen = .onboardingView
    @State private var showingModalView = false

    // Folders
    @StateObject var deleteFolderAide = DeleteFolderViewAideiPhone()

    // May be dropped
    @State private var authorSortOption: Int = 0
    @State private var soundSortOption: Int = 0

    // MARK: - Computed Properties

    private var title: String {
        guard currentSoundsListMode == .regular else {
            if selectionKeeper.count == 0 {
                return Shared.SoundSelection.selectSounds
            } else if selectionKeeper.count == 1 {
                return Shared.SoundSelection.soundSelectedSingular
            } else {
                return String(format: Shared.SoundSelection.soundsSelectedPlural, selectionKeeper.count)
            }
        }
        switch viewModel.currentViewMode {
        case .allSounds:
            return "Sons"
        case .favorites:
            return "Favoritos"
        case .folders:
            return "Minhas Pastas"
        case .byAuthor:
            return "Autores"
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            VStack {
                switch viewModel.currentViewMode {
                case .allSounds:
                    SoundList(
                        viewModel: .init(
                            provider: viewModel,
                            sections: [.sharingOptions(), .organizingOptions(), .detailsOptions()]
                        ),
                        currentSoundsListMode: $currentSoundsListMode
                    )
                case .favorites:
                    SoundList(
                        viewModel: .init(
                            provider: viewModel,
                            sections: [.sharingOptions(), .organizingOptions(), .detailsOptions()]
                        ),
                        currentSoundsListMode: $currentSoundsListMode
                    )
                case .folders:
                    MyFoldersiPhoneView()
                        .environmentObject(deleteFolderAide)
                case .byAuthor:
                    AuthorsView(
                        sortOption: .constant(0),
                        sortAction: .constant(.nameAscending),
                        searchTextForControl: .constant("")
                    )
                }
            }
            .navigationTitle(Text(title))
            .navigationBarItems(
                leading: leadingToolbarControls(),
                trailing: trailingToolbarControls()
            )
            .onAppear {
                print("PHONE SOUNDS CONTAINER - ON APPEAR")
                viewModel.reloadList(currentMode: viewModel.currentViewMode)
            }
        }
    }

    @ViewBuilder func leadingToolbarControls() -> some View {
        if currentSoundsListMode == .selection {
            Button {
                currentSoundsListMode = .regular
                selectionKeeper.removeAll()
            } label: {
                Text("Cancelar")
                    .bold()
            }
        } else {
            if UIDevice.isiPhone {
                Button {
                    subviewToOpen = .settingsView
                    showingModalView = true
                } label: {
                    Image(systemName: "gearshape")
                }
            } else {
                EmptyView()
            }
        }
    }

    @ViewBuilder func trailingToolbarControls() -> some View {
        if viewModel.currentViewMode == .folders {
            EmptyView()
        } else {
            HStack(spacing: 15) {
                if viewModel.currentViewMode == .byAuthor {
                    Menu {
                        Section {
                            Picker("Ordenação de Autores", selection: $authorSortOption) {
                                Text("Nome")
                                    .tag(0)

                                Text("Autores com Mais Sons no Topo")
                                    .tag(1)

                                Text("Autores com Menos Sons no Topo")
                                    .tag(2)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
//                    .onChange(of: authorSortOption, perform: { authorSortOption in
//                        authorSortAction = AuthorSortOption(rawValue: authorSortOption) ?? .nameAscending
//                    })
                } else {
                    if currentSoundsListMode == .regular {
                        SyncStatusView()
                            .onTapGesture {
                                subviewToOpen = .syncInfoView
                                showingModalView = true
                            }
                    }

                    Menu {
                        Section {
                            Button {
                                // viewModel.startSelecting()
                            } label: {
                                Label(currentSoundsListMode == .selection ? "Cancelar Seleção" : "Selecionar", systemImage: currentSoundsListMode == .selection ? "xmark.circle" : "checkmark.circle")
                            }//.disabled(viewModel.currentViewMode == .favorites && viewModel.sounds.count == 0)
                        }

                        Section {
                            Picker("Ordenação de Sons", selection: $soundSortOption) {
                                Text("Título")
                                    .tag(0)

                                Text("Nome do(a) Autor(a)")
                                    .tag(1)

                                Text("Mais Recentes no Topo")
                                    .tag(2)

                                Text("Mais Curtos no Topo")
                                    .tag(3)

                                Text("Mais Longos no Topo")
                                    .tag(4)

                                if CommandLine.arguments.contains("-UNDER_DEVELOPMENT") {
                                    Text("Título Mais Longo no Topo")
                                        .tag(5)

                                    Text("Título Mais Curto no Topo")
                                        .tag(6)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
//                    .onChange(of: viewModel.soundSortOption) {
//                        viewModel.sortSounds(by: SoundSortOption(rawValue: $0) ?? .dateAddedDescending)
//                        UserSettings.setSoundSortOption(to: $0)
//                    }
                }
            }
        }
    }
}

#Preview {
    PhoneSoundsContainer(
        viewModel: .init(
            currentViewMode: .allSounds,
            soundSortOption: SoundSortOption.dateAddedDescending.rawValue,
            authorSortOption: AuthorSortOption.nameAscending.rawValue,
            currentSoundsListMode: .constant(.regular)
        ),
        currentSoundsListMode: .constant(.regular)
    )
}
