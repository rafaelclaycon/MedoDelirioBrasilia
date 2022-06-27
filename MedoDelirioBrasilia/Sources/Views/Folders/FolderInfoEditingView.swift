import SwiftUI
import Combine

struct FolderInfoEditingView: View {

    private enum Field: Int, Hashable {
        case symbol, folderName
    }
    
    @StateObject var viewModel = FolderInfoEditingViewViewModel()
    @Binding var isBeingShown: Bool
    @State var symbol: String = ""
    @State var folderName: String = ""
    @State var selectedBackgroundColor: String
    @State var isEditing: Bool = false
    @State var folderIdWhenEditing: String = ""
    @FocusState private var focusedField: Field?
    
    private let rows = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(selectedBackgroundColor.toColor())
                        .frame(width: 180, height: 100)
                    
                    HStack {
                        Spacer()
                        
                        TextField("", text: $symbol)
                            .font(.system(size: 50))
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                            .onReceive(Just(symbol)) { _ in
                                limitSymbolText(1)
                            }
                            .focused($focusedField, equals: .symbol)
                        
                        Spacer()
                    }
                }
                
                Text("Digite um emoji no retângulo acima para representar a pasta.")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
                
                VStack {
                    TextField("Nome da pasta", text: $folderName)
                        .textFieldStyle(.roundedBorder)
                        .onReceive(Just(folderName)) { _ in
                            limitFolderNameText(25)
                        }
                        .focused($focusedField, equals: .folderName)
                    
                    HStack {
                        Spacer()
                        
                        Text("\(folderName.count)/25")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                ScrollView(.horizontal, showsIndicators: true) {
                    LazyHGrid(rows: rows, spacing: 5) {
                        ForEach(FolderColorFactory.getColors()) { folderColor in
                            ColorSelectionCell(color: folderColor.color, selectedColor: $selectedBackgroundColor)
                        }
                    }
                    .frame(height: 70)
                    .padding(.leading)
                    .padding(.trailing)
                }
            }
            .navigationTitle(isEditing ? "Editar Pasta" : "Nova Pasta")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                Button(action: {
                    self.isBeingShown = false
                }) {
                    Text("Cancelar")
                }
            , trailing:
                Button(action: {
                    if viewModel.checkIfMeetsAllRequirements(symbol: symbol, folderName: folderName, isEditing: isEditing) {
                        if isEditing {
                            guard folderIdWhenEditing.isEmpty == false else {
                                return
                            }
                            try? database.update(userFolder: folderIdWhenEditing, withNewSymbol: symbol, newName: folderName, andNewBackgroundColor: selectedBackgroundColor)
                            self.isBeingShown = false
                        } else {
                            try? database.insert(userFolder: UserFolder(symbol: symbol, name: folderName, backgroundColor: selectedBackgroundColor))
                            self.isBeingShown = false
                        }
                    }
                }) {
                    Text(isEditing ? "Salvar" : "Criar")
                        .bold()
                }
                .disabled(symbol.isEmpty || folderName.isEmpty)
            )
            .alert(isPresented: $viewModel.showAlert) { 
                Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                    if isEditing {
                        focusedField = .folderName
                    } else {
                        focusedField = .symbol
                    }
                }
            }
        }
    }
    
    private func limitSymbolText(_ upper: Int) {
        if symbol.count > upper {
            symbol = String(symbol.prefix(upper))
        }
    }
    
    private func limitFolderNameText(_ upper: Int) {
        if folderName.count > upper {
            folderName = String(folderName.prefix(upper))
        }
    }

}

struct FolderInfoEditingView_Previews: PreviewProvider {

    static var previews: some View {
        FolderInfoEditingView(isBeingShown: .constant(true), selectedBackgroundColor: "pastelBabyBlue")
    }

}
