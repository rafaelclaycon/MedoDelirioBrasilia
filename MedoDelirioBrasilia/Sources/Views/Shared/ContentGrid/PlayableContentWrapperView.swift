//
//  PlayableContentWrapperView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 10/05/25.
//

import SwiftUI

struct PlayableContentWrapperView<InnerView: View>: View {

    @Binding var showAlert: Bool
    @Binding var showModalView: Bool
    @Binding var showiPadShareSheet: Bool

    let alertType: PlayableContentAlert
    let subviewToOpen: ContentGridModalToOpen
    let iPadShareSheet: ActivityViewController

    let alertTitle: String
    let alertMessage: String
    let onRedownloadContentOptionSelected: () -> Void
    let onReportContentIssueSelected: () -> Void

    let innerView: InnerView

    var body: some View {
        VStack {
            innerView
        }
        .alert(isPresented: $showAlert) {
            switch alertType {
            case .contentFileNotFound:
                return Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    primaryButton: .default(
                        Text("Baixar Novamente"),
                        action: { onRedownloadContentOptionSelected() }
                    ),
                    secondaryButton: .cancel(Text("Fechar"))
                )

            case .issueSharingContent:
                return Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    primaryButton: .default(
                        Text("Relatar Problema por E-mail"),
                        action: { onReportContentIssueSelected() }
                    ),
                    secondaryButton: .cancel(Text("Fechar"))
                )

            case .unableToRedownloadContent:
                return Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
//        .sheet(isPresented: $showModalView) {
//            switch subviewToOpen {
//            case .shareAsVideo:
//                ShareAsVideoView(
//                    viewModel: ShareAsVideoViewModel(
//                        content: selectedContentSingle!,
//                        subtitle: selectedContentSingle!.subtitle,
//                        contentType: typeForShareAsVideo(),
//                        result: $shareAsVideoResult
//                    ),
//                    useLongerGeneratingVideoMessage: selectedContentSingle!.type == .song
//                )
//
//            case .addToFolder:
//                AddToFolderView(
//                    isBeingShown: $showModalView,
//                    details: $addToFolderHelper,
//                    selectedContent: selectedContentMultiple ?? []
//                )
//
//            case .contentDetail:
//                ContentDetailView(
//                    content: selectedContentSingle ?? AnyEquatableMedoContent(Sound(title: "")),
//                    openAuthorDetailsAction: { author in
//                        guard author.id != self.authorId else { return }
//                        showModalView.toggle()
//                        push(GeneralNavigationDestination.authorDetail(author))
//                    },
//                    authorId: authorId,
//                    openReactionAction: { reaction in
//                        showModalView.toggle()
//                        push(GeneralNavigationDestination.reactionDetail(reaction))
//                    },
//                    reactionId: reactionId,
//                    dismissAction: { showModalView = false }
//                )
//
//            case .soundIssueEmailPicker:
//                EmailAppPickerView(
//                    isBeingShown: $showModalView,
//                    toast: toast,
//                    subject: Shared.issueSuggestionEmailSubject,
//                    emailBody: Shared.issueSuggestionEmailBody
//                )
//
//            case .authorIssueEmailPicker(let content):
//                EmailAppPickerView(
//                    isBeingShown: $showModalView,
//                    toast: toast,
//                    subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, content.title),
//                    emailBody: String(format: Shared.suggestOtherAuthorNameEmailBody, content.subtitle, content.id)
//                )
//            }
//        }
        .sheet(isPresented: $showiPadShareSheet) {
            iPadShareSheet
        }
//        .onChange(of: viewModel.shareAsVideoResult.videoFilepath) {
//            viewModel.onDidExitShareAsVideoSheet()
//        }
//        .onChange(of: showModalView) {
//            if (showModalView == false) && addToFolderHelper.hadSuccess {
//                Task {
//                    await viewModel.onAddedContentToFolderSuccessfully(
//                        folderName: addToFolderHelper.folderName ?? "",
//                        pluralization: addToFolderHelper.pluralization
//                    )
//                    addToFolderHelper = AddToFolderDetails()
//                }
//            }
//        }
//        .onChange(of: viewModel.authorToOpen) {
//            guard let author = viewModel.authorToOpen else { return }
//            push(GeneralNavigationDestination.authorDetail(author))
//            viewModel.authorToOpen = nil
//        }
    }
}

#Preview {
    PlayableContentWrapperView(
        showAlert: .constant(false),
        showModalView: .constant(false),
        showiPadShareSheet: .constant(false),
        alertType: .contentFileNotFound,
        subviewToOpen: .addToFolder,
        iPadShareSheet: ActivityViewController(
            activityItems: [],
            completionWithItemsHandler: nil,
            applicationActivities: nil
        ),
        alertTitle: "",
        alertMessage: "",
        onRedownloadContentOptionSelected: {
        },
        onReportContentIssueSelected: {},
        innerView: VStack {
            Text("Inner View")
        }
    )
}
