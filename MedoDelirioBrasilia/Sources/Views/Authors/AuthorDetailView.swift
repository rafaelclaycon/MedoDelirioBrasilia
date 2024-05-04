//
//  AuthorDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import SwiftUI
import Kingfisher

struct AuthorDetailView: View {

    @StateObject var viewModel: AuthorDetailViewViewModel

    let author: Author

    @State private var navBarTitle: String = .empty
    @Binding var currentSoundsListMode: SoundsListMode
    @State private var showSelectionControlsInToolbar = false
    @State private var showMenuOnToolbarForiOS16AndHigher = false
    
    @State private var listWidth: CGFloat = 700
    @State private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    @Environment(\.sizeCategory) var sizeCategory
    
    @State private var showingModalView = false
    
    // Add to Folder vars
    @State private var showingAddToFolderModal = false
    @State private var hadSuccessAddingToFolder: Bool = false
    @State private var folderName: String? = nil
    @State private var pluralization: WordPluralization = .singular
    @State private var shouldDisplayAddedToFolderToast: Bool = false
    
    // Share as Video
    @State private var shareAsVideo_Result = ShareAsVideoResult()
    
    private var edgesToIgnore: SwiftUI.Edge.Set {
        return author.photo == nil ? [] : .top
    }

    private func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }
    
    private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        // Image was pulled down
        if offset > 0 {
            return -offset
        }
        return 0
    }
    
    private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height
        if offset > 0 {
            return imageHeight + offset
        }
        return imageHeight
    }
    
    private func getOffsetBeforeShowingTitle() -> CGFloat {
        author.photo == nil ? 50 : 250
    }
    
    private func updateNavBarContent(_ offset: CGFloat) {
        if offset < getOffsetBeforeShowingTitle() {
            DispatchQueue.main.async {
                navBarTitle = title
                showSelectionControlsInToolbar = currentSoundsListMode == .selection
                showMenuOnToolbarForiOS16AndHigher = currentSoundsListMode == .regular
            }
        } else {
            DispatchQueue.main.async {
                navBarTitle = .empty
                showSelectionControlsInToolbar = false
                showMenuOnToolbarForiOS16AndHigher = false
            }
        }
    }

    // MARK: - Computed Properties

    private var title: String {
        guard currentSoundsListMode == .regular else {
            if viewModel.selectionKeeper.count == 0 {
                return Shared.SoundSelection.selectSounds
            } else if viewModel.selectionKeeper.count == 1 {
                return Shared.SoundSelection.soundSelectedSingular
            } else {
                return String(format: Shared.SoundSelection.soundsSelectedPlural, viewModel.selectionKeeper.count)
            }
        }
        return author.name
    }

    private var externalLinks: [ExternalLink] {
        guard let links = author.externalLinks else {
            return []
        }
        guard let jsonData = links.data(using: .utf8) else {
            return []
        }
        let decoder = JSONDecoder()
        do {
            let decodedLinks = try decoder.decode([ExternalLink].self, from: jsonData)
            return decodedLinks
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }

    // MARK: - View Body

    var body: some View {
        VStack {
            SoundList(
                viewModel: .init(
                    data: viewModel.soundsPublisher,
                    menuOptions: [.sharingOptions(), .organizingOptions(), .authorOptions()],
                    currentSoundsListMode: .constant(.regular)
                ),
                stopShowingFloatingSelector: .constant(nil),
                emptyStateView: AnyView(
                    NoSoundsView()
                        .padding(.horizontal, 25)
                ),
                headerView: AnyView(
                    VStack{
                        if let photo = author.photo {
                            GeometryReader { headerPhotoGeometry in
                                KFImage(URL(string: photo))
                                    .placeholder {
                                        Image(systemName: "photo.on.rectangle")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 100)
                                            .foregroundColor(.gray)
                                            .opacity(0.3)
                                    }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: headerPhotoGeometry.size.width, height: self.getHeightForHeaderImage(headerPhotoGeometry))
                                    .clipped()
                                    .offset(x: 0, y: self.getOffsetForHeaderImage(headerPhotoGeometry))
                            }.frame(height: 250)
                        }

                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text(title)
                                    .font(.title)
                                    .bold()

                                Spacer()

                                moreOptionsMenu(isOnToolbar: false)
                            }

                            if currentSoundsListMode == .selection {
                                inlineSelectionControls()
                            } else {
                                if author.description != nil {
                                    Text(author.description ?? "")
                                }

                                if !externalLinks.isEmpty {
                                    ViewThatFits(in: .horizontal) {
                                        HStack(spacing: 10) {
                                            ForEach(externalLinks, id: \.title) {
                                                ExternalLinkButton(externalLink: $0)
                                            }
                                        }
                                        VStack(alignment: .leading, spacing: 15) {
                                            ForEach(externalLinks, id: \.title) {
                                                ExternalLinkButton(externalLink: $0)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }

                                Text(viewModel.getSoundCount())
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .bold()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                    }
                )
            )
        }
        //.navigationTitle(navBarTitle)
        .onPreferenceChange(ViewOffsetKey.self) { offset in
            updateNavBarContent(offset)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if currentSoundsListMode != .regular {
                // On scroll, show Select controls if not at the top
                if showSelectionControlsInToolbar {
                    toolbarSelectionControls()
                }
            }
        }
        .onAppear {
            // TODO: Refactor this to be closer to SoundsView.
            viewModel.reloadList(
                withSounds: try? LocalDatabase.shared.allSounds(forAuthor: author.id, isSensitiveContentAllowed: UserSettings.getShowExplicitContent()),
                andFavorites: try? LocalDatabase.shared.favorites()
            )

            columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)
        }
        .onDisappear {
            if currentSoundsListMode == .selection {
                viewModel.stopSelecting()
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            switch viewModel.alertType {
            case .ok:
                return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            case .reportSoundIssue:
                return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), primaryButton: .default(Text("Relatar Problema por E-mail"), action: {
                    viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog = true
                }), secondaryButton: .cancel(Text("Fechar")))
            case .askForNewSound:
                return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), primaryButton: .default(Text("Li e Entendi"), action: {
                    viewModel.showEmailAppPicker_askForNewSound = true
                }), secondaryButton: .cancel(Text("Cancelar")))
            }
        }
        .sheet(isPresented: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog) {
            EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog,
                               didCopySupportAddress: .constant(false),
                               subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, viewModel.selectedSound?.title ?? ""),
                               emailBody: String(format: Shared.suggestOtherAuthorNameEmailBody, viewModel.selectedSound?.authorName ?? "", viewModel.selectedSound?.id ?? ""))
        }
        .sheet(isPresented: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog) {
            EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog,
                               didCopySupportAddress: .constant(false),
                               subject: Shared.issueSuggestionEmailSubject,
                               emailBody: Shared.issueSuggestionEmailBody)
        }
        .sheet(isPresented: $viewModel.showEmailAppPicker_askForNewSound) {
            EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_askForNewSound,
                               didCopySupportAddress: .constant(false),
                               subject: String(format: Shared.Email.AskForNewSound.subject, self.author.name),
                               emailBody: Shared.Email.AskForNewSound.body)
        }
        .sheet(isPresented: $viewModel.showEmailAppPicker_reportAuthorDetailIssue) {
            EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_reportAuthorDetailIssue,
                               didCopySupportAddress: .constant(false),
                               subject: String(format: Shared.Email.AuthorDetailIssue.subject, self.author.name),
                               emailBody: Shared.Email.AuthorDetailIssue.body)
        }
        .onChange(of: viewModel.selectionKeeper.count) { selectionKeeperCount in
            if navBarTitle.isEmpty == false {
                DispatchQueue.main.async {
                    navBarTitle = title
                }
            }
        }
        .edgesIgnoringSafeArea(edgesToIgnore)
    }
    
    @ViewBuilder func moreOptionsMenu(isOnToolbar: Bool) -> some View {
        Menu {
            if viewModel.sounds.count > 1 {
                Section {
                    Button {
                        viewModel.startSelecting()
                    } label: {
                        Label(currentSoundsListMode == .selection ? "Cancelar Seleção" : "Selecionar", systemImage: currentSoundsListMode == .selection ? "xmark.circle" : "checkmark.circle")
                    }
                }
            }
            
            Section {
                Button {
                    viewModel.stopSelecting()
                    viewModel.selectedSounds = viewModel.sounds
                    showingAddToFolderModal = true
                } label: {
                    Label("Adicionar Todos a Pasta", systemImage: "folder.badge.plus")
                }
                
                Button {
                    viewModel.stopSelecting()
                    viewModel.showAskForNewSoundAlert()
                } label: {
                    Label("Pedir Som Desse Autor", systemImage: "plus.circle")
                }
                
                Button {
                    viewModel.stopSelecting()
                    viewModel.showEmailAppPicker_reportAuthorDetailIssue = true
                } label: {
                    Label("Relatar Problema com os Detalhes Desse Autor", systemImage: "person.crop.circle.badge.exclamationmark")
                }
            }
            
            if viewModel.sounds.count > 1 {
                Section {
                    Picker("Ordenação de Sons", selection: $viewModel.soundSortOption) {
                        Text("Título")
                            .tag(0)
                        
                        Text("Mais Recentes no Topo")
                            .tag(1)
                    }
                    .onChange(of: viewModel.soundSortOption, perform: { soundSortOption in
                        if soundSortOption == 0 {
                            viewModel.sortSoundsInPlaceByTitleAscending()
                        } else {
                            viewModel.sortSoundsInPlaceByDateAddedDescending()
                        }
                    })
                }
            }
        } label: {
            if isOnToolbar {
                Image(systemName: "ellipsis.circle")
            } else {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 26)
            }
        }
        .disabled(viewModel.sounds.count == 0)
    }
    
    @ViewBuilder func inlineSelectionControls() -> some View {
        HStack(spacing: 25) {
            Button {
                cancelSelectionAction()
            } label: {
                Text("Cancelar")
                    .bold()
            }
            
            Button {
                favoriteAction()
            } label: {
                Label("Favoritos", systemImage: viewModel.allSelectedAreFavorites() ? "star.slash" : "star")
            }.disabled(viewModel.selectionKeeper.count == 0)
            
            Button {
                addToFolderAction()
            } label: {
                Label("Pasta", systemImage: "folder.badge.plus")
            }.disabled(viewModel.selectionKeeper.count == 0)
        }
        .padding(.vertical, 10)
    }
    
    @ViewBuilder func toolbarSelectionControls() -> some View {
        HStack(spacing: 15) {
            Button {
                cancelSelectionAction()
            } label: {
                Text("Cancelar")
                    .bold()
            }
            
            Button {
                favoriteAction()
            } label: {
                Image(systemName: viewModel.allSelectedAreFavorites() ? "star.slash" : "star")
            }.disabled(viewModel.selectionKeeper.count == 0)
            
            Button {
                addToFolderAction()
            } label: {
                Image(systemName: "folder.badge.plus")
            }.disabled(viewModel.selectionKeeper.count == 0)
            
            moreOptionsMenu(isOnToolbar: true)
        }
    }
    
    private func cancelSelectionAction() {
        currentSoundsListMode = .regular
        viewModel.selectionKeeper.removeAll()
    }
    
    private func favoriteAction() {
        // Need to get count before clearing the Set.
        let selectedCount: Int = viewModel.selectionKeeper.count
        
        if viewModel.allSelectedAreFavorites() {
            viewModel.removeSelectedFromFavorites()
            viewModel.stopSelecting()
            viewModel.reloadList(
                withSounds: try? LocalDatabase.shared.allSounds(forAuthor: author.id, isSensitiveContentAllowed: UserSettings.getShowExplicitContent()),
                andFavorites: try? LocalDatabase.shared.favorites()
            )
            viewModel.sendUsageMetricToServer(action: "didRemoveManySoundsFromFavorites(\(selectedCount))", authorName: author.name)
        } else {
            viewModel.addSelectedToFavorites()
            viewModel.stopSelecting()
            viewModel.sendUsageMetricToServer(action: "didAddManySoundsToFavorites(\(selectedCount))", authorName: author.name)
        }
    }
    
    private func addToFolderAction() {
        viewModel.prepareSelectedToAddToFolder()
        showingAddToFolderModal = true
    }

}

struct ViewOffsetKey: PreferenceKey {

    typealias Value = CGFloat
    
    static var defaultValue = CGFloat.zero
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }

}

#Preview {
    AuthorDetailView(
        viewModel: .init(authorName: "João da Silva", currentSoundsListMode: .constant(.selection)),
        author: .init(
            id: "0D944922-7E50-4DED-A8FD-F44EFCAE82A2",
            name: "Abraham Weintraub",
            photo: "https://conteudo.imguol.com.br/c/noticias/fd/2020/06/22/11fev2020---o-entao-ministro-da-educacao-abraham-weintraub-falando-a-comissao-do-senado-sobre-problemas-na-correcao-das-provas-do-enem-1592860563916_v2_3x4.jpg",
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam."
        ),
        currentSoundsListMode: .constant(.regular)
    )
}
