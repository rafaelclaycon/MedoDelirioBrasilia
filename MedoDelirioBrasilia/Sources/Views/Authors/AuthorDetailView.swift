//
//  AuthorDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import SwiftUI

struct AuthorDetailView: View {

    @State private var viewModel: AuthorDetailViewModel
    @State private var contentGridViewModel: ContentGridViewModel

    @State private var navBarTitle: String = ""
    private var currentContentListMode: Binding<ContentGridMode>

    @State private var showingModalView = false

    // MARK: - Computed Properties

    private var title: String {
        guard currentContentListMode.wrappedValue == .regular else {
            if contentGridViewModel.selectionKeeper.count == 0 {
                return Shared.SoundSelection.selectSounds
            } else if contentGridViewModel.selectionKeeper.count == 1 {
                return Shared.SoundSelection.soundSelectedSingular
            } else {
                return String(
                    format: Shared.SoundSelection.soundsSelectedPlural,
                    contentGridViewModel.selectionKeeper.count
                )
            }
        }
        return viewModel.author.name
    }

    private var edgesToIgnore: SwiftUI.Edge.Set {
        return viewModel.author.photo == nil ? [] : .top
    }

    private func getOffsetBeforeShowingTitle() -> CGFloat {
        viewModel.author.photo == nil ? 50 : 250
    }

    private func updateNavBarContent(_ offset: CGFloat) {
        if offset < getOffsetBeforeShowingTitle() {
            DispatchQueue.main.async {
                navBarTitle = title
            }
        } else {
            DispatchQueue.main.async {
                navBarTitle = ""
            }
        }
    }

    private var loadedContent: [AnyEquatableMedoContent] {
        guard case .loaded(let content) = viewModel.state else { return [] }
        return content
    }

    // MARK: - Initializer

    init(
        viewModel: AuthorDetailViewModel,
        currentListMode: Binding<ContentGridMode>,
        contentRepository: ContentRepositoryProtocol
    ) {
        self.viewModel = viewModel
        self.currentContentListMode = currentListMode
        self.contentGridViewModel = ContentGridViewModel(
            contentRepository: contentRepository,
            searchService: SearchService(
                database: LocalDatabase.shared,
                contentRepository: contentRepository,
                authorService: AuthorService(database: LocalDatabase.shared)
            ),
            userFolderRepository: UserFolderRepository(database: LocalDatabase.shared),
            screen: .authorDetailView,
            menuOptions: [.sharingOptions(), .organizingOptions(), .playFromThisSound(), .authorOptions()],
            currentListMode: currentListMode,
            toast: viewModel.toast,
            floatingOptions: viewModel.floatingOptions,
            analyticsService: AnalyticsService()
        )
    }

    // MARK: - View Body

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: .spacing(.medium)) {
                    AuthorHeaderView(
                        author: viewModel.author,
                        title: title,
                        soundCount: viewModel.soundCount,
                        soundCountText: viewModel.soundCountText,
                        containerWidth: geometry.size.width,
                        contentListMode: currentContentListMode.wrappedValue,
                        contentSortOption: $viewModel.soundSortOption,
                        multiSelectAction: {
                            contentGridViewModel.onEnterMultiSelectModeSelected(
                                loadedContent: loadedContent,
                                isFavoritesOnlyView: false
                            )
                        },
                        askForSoundAction: {
                            contentGridViewModel.onExitMultiSelectModeSelected()
                            viewModel.showAskForNewSoundAlert()
                        },
                        reportIssueAction: {
                            contentGridViewModel.onExitMultiSelectModeSelected()
                            viewModel.showEmailAppPicker_reportAuthorDetailIssue = true
                        },
                        contentSortChangeAction: {
                            contentGridViewModel.onContentSortingChanged()
                            viewModel.onSortOptionChanged()
                        }
                    )

                    ContentGrid(
                        state: viewModel.state,
                        viewModel: contentGridViewModel,
                        authorId: viewModel.author.id,
                        containerSize: geometry.size,
                        loadingView:
                            VStack {
                                HStack(spacing: 10) {
                                    ProgressView()

                                    Text("Carregando sons...")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        ,
                        emptyStateView:
                            VStack {
                                NoSoundsView()
                                    .padding(.horizontal, 25)
                            }
                        ,
                        errorView:
                            VStack {
                                HStack(spacing: 10) {
                                    ProgressView()

                                    Text("Erro ao carregar sons.")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                            }
                    )
                    .environment(TrendsHelper())
                    .padding(.horizontal, .spacing(.medium))

                    Spacer()
                        .frame(height: .spacing(.large))
                }
                .onPreferenceChange(ViewOffsetKey.self) { offset in
                    updateNavBarContent(offset)
                }
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    viewModel.onViewLoaded()
                }
                .onDisappear {
                    contentGridViewModel.onViewDisappeared()
                }
                .alert(isPresented: $viewModel.showAlert) {
                    switch viewModel.alertType {
                    case .ok:
                        return Alert(
                            title: Text(viewModel.alertTitle),
                            message: Text(viewModel.alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    case .reportSoundIssue:
                        return Alert(
                            title: Text(viewModel.alertTitle),
                            message: Text(viewModel.alertMessage),
                            primaryButton: .default(Text("Relatar Problema por E-mail"), action: { viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog = true }),
                            secondaryButton: .cancel(Text("Fechar"))
                        )
                    case .askForNewSound:
                        return Alert(
                            title: Text(viewModel.alertTitle),
                            message: Text(viewModel.alertMessage),
                            primaryButton: .default(Text("Li e Entendi"), action: { viewModel.showEmailAppPicker_askForNewSound = true }),
                            secondaryButton: .cancel(Text("Cancelar"))
                        )
                    }
                }
                .sheet(isPresented: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog) {
                    EmailAppPickerView(
                        isBeingShown: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog,
                        toast: contentGridViewModel.toast,
                        subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, viewModel.selectedSound?.title ?? ""),
                        emailBody: String(format: Shared.suggestOtherAuthorNameEmailBody, viewModel.selectedSound?.authorName ?? "", viewModel.selectedSound?.id ?? "")
                    )
                }
                .sheet(isPresented: $viewModel.showEmailAppPicker_askForNewSound) {
                    EmailAppPickerView(
                        isBeingShown: $viewModel.showEmailAppPicker_askForNewSound,
                        toast: contentGridViewModel.toast,
                        subject: String(format: Shared.Email.AskForNewSound.subject, self.viewModel.author.name),
                        emailBody: Shared.Email.AskForNewSound.body
                    )
                }
                .sheet(isPresented: $viewModel.showEmailAppPicker_reportAuthorDetailIssue) {
                    EmailAppPickerView(
                        isBeingShown: $viewModel.showEmailAppPicker_reportAuthorDetailIssue,
                        toast: contentGridViewModel.toast,
                        subject: String(format: Shared.Email.AuthorDetailIssue.subject, self.viewModel.author.name),
                        emailBody: Shared.Email.AuthorDetailIssue.body
                    )
                }
                .onChange(of: contentGridViewModel.selectionKeeper.count) {
                    if navBarTitle.isEmpty == false {
                        DispatchQueue.main.async {
                            navBarTitle = title
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(edgesToIgnore)
            .toast(viewModel.toast)
            .floatingContentOptions(viewModel.floatingOptions)
        }
    }
}

struct ViewOffsetKey: PreferenceKey {

    typealias Value = CGFloat

    static var defaultValue = CGFloat.zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

// MARK: - Preview

#Preview {
    let author = Author(
        id: "0D944922-7E50-4DED-A8FD-F44EFCAE82A2",
        name: "Abraham Weintraub",
        photo: "https://conteudo.imguol.com.br/c/noticias/fd/2020/06/22/11fev2020---o-entao-ministro-da-educacao-abraham-weintraub-falando-a-comissao-do-senado-sobre-problemas-na-correcao-das-provas-do-enem-1592860563916_v2_3x4.jpg",
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam."
    )

    AuthorDetailView(
        viewModel: AuthorDetailViewModel(
            author: author,
            currentContentListMode: .constant(.regular),
            toast: .constant(nil),
            floatingOptions: .constant(nil),
            contentRepository: FakeContentRepository()
        ),
        currentListMode: .constant(.regular),
        contentRepository: FakeContentRepository()
    )
}
