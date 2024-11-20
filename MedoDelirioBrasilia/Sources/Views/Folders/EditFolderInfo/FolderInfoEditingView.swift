//
//  FolderInfoEditingView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI
import Combine

struct FolderInfoEditingView: View {

    @StateObject private var viewModel: ViewModel

    @FocusState private var focusedField: Field?

    private let dismissSheet: () -> Void

    // MARK: - Initializer

    init(
        folder: UserFolder,
        folderRepository: UserFolderRepositoryProtocol,
        dismissSheet: @escaping () -> Void
    ) {
        self._viewModel = StateObject(
            wrappedValue: ViewModel(
                folder: folder,
                folderRepository: folderRepository,
                dismissSheet: dismissSheet
            )
        )
        self.dismissSheet = dismissSheet
    }

    // MARK: - View Body

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                EmojiField(
                    symbol: $viewModel.folder.symbol,
                    backgroundColor: viewModel.folder.backgroundColor.toPastelColor()
                )
                .focused($focusedField, equals: .symbol)

                Text("Digite um emoji no retângulo acima para representar a pasta.")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
                    .onTapGesture {
                        focusedField = nil
                    }
                
                if ProcessInfo.processInfo.isMacCatalystApp {
                    Text("Para acessar os emojis no Mac, pressione Control + Command + Espaço.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                NameField(name: $viewModel.folder.name)
                    .focused($focusedField, equals: .folderName)

                Spacer()
                
                ColorPicker(
                    selectedBackgroundColor: viewModel.folder.backgroundColor,
                    colorSelectionAction: { viewModel.onPickedColorChanged($0) }
                )
            }
            .navigationTitle(viewModel.isEditing ? "Editar Pasta" : "Nova Pasta")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading:
                    Button("Cancelar") {
                        dismissSheet()
                    }
                ,
                trailing:
                    Button {
                        viewModel.onSaveSelected()
                    } label: {
                        Text(viewModel.isEditing ? "Salvar" : "Criar")
                            .bold()
                    }
                    .disabled(viewModel.saveCreateButtonIsDisabled)
            )
            .alert(isPresented: $viewModel.showAlert) { 
                Alert(
                    title: Text(viewModel.alertTitle),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                    if viewModel.isEditing {
                        focusedField = .folderName
                    } else {
                        focusedField = .symbol
                    }
                }
            }
        }
    }
}

// MARK: - Field

extension FolderInfoEditingView {

    internal enum Field: Int, Hashable {
        case symbol, folderName
    }
}

// MARK: - Subviews

extension FolderInfoEditingView {

    struct EmojiField: View {

        @Binding var symbol: String
        let backgroundColor: Color

        var body: some View {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(backgroundColor)
                .frame(width: 180, height: 100)
                .overlay {
                    HStack {
                        Spacer()

                        TextField("", text: $symbol)
                            .font(.system(size: 50))
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                            .onReceive(Just(symbol)) { _ in
                                limitSymbolText(1)
                            }

                        Spacer()
                    }
                }
        }

        private func limitSymbolText(_ upper: Int) {
            if symbol.count > upper {
                symbol = String(symbol.prefix(upper))
            }
        }
    }

    struct NameField: View {

        @Binding var name: String

        var body: some View {
            VStack {
                TextField("Nome da pasta", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .onReceive(Just(name)) { _ in
                        limitFolderNameText(25)
                    }


                HStack {
                    Spacer()

                    Text("\(name.count)/25")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
        }

        private func limitFolderNameText(_ upper: Int) {
            if name.count > upper {
                name = String(name.prefix(upper))
            }
        }
    }

    struct ColorPicker: View {

        let selectedBackgroundColor: String
        let colorSelectionAction: (String) -> Void

        private let colorRow = [
            GridItem(.flexible())
        ]

        var body: some View {
            ScrollView(.horizontal, showsIndicators: true) {
                LazyHGrid(rows: colorRow, spacing: 5) {
                    ForEach(FolderColorFactory.getColors()) { folderColor in
                        ColorSelectionCell(
                            color: folderColor.color,
                            isSelected: folderColor.id == selectedBackgroundColor,
                            colorSelectionAction: colorSelectionAction
                        )
                    }
                }
                .frame(height: 70)
                .padding(.leading)
                .padding(.trailing)
            }
        }
    }
}

// MARK: - Preview

#Preview("New Folder") {
    FolderInfoEditingView(
        folder: .init(
            symbol: "",
            name: "",
            backgroundColor: "",
            changeHash: ""
        ),
        folderRepository: UserFolderRepository(),
        dismissSheet: {}
    )
}
