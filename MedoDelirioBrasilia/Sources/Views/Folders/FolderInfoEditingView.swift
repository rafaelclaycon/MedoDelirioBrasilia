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
    @State var backgroundColor: Color = .pastelBabyBlue
    @State var isEditing: Bool = false
    @FocusState private var focusedField: Field?
    
    let colors: [FolderColor] = [FolderColor(color: .pastelPurple), FolderColor(color: .pastelBabyBlue),
                                 FolderColor(color: .pastelBrightGreen), FolderColor(color: .pastelYellow),
                                 FolderColor(color: .pastelOrange), FolderColor(color: .pastelPink),
                                 FolderColor(color: .pastelGray), FolderColor(color: .pastelRoyalBlue),
                                 FolderColor(color: .pastelMutedGreen), FolderColor(color: .pastelRed),
                                 FolderColor(color: .pastelBeige)]
    
    let rows = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(backgroundColor)
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
                    LazyHGrid(rows: rows, spacing: 14) {
                        ForEach(colors) { folderColor in
                            Circle()
                                .fill(folderColor.color)
                                .frame(width: 40, height: 40)
                                .onTapGesture {
                                    backgroundColor = folderColor.color
                                }
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
                        try? database.insert(userFolder: UserFolder(symbol: symbol, title: folderName, backgroundColor: backgroundColor.name ?? .empty))
                        self.isBeingShown = false
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

struct AddNewFolderView_Previews: PreviewProvider {

    static var previews: some View {
        FolderInfoEditingView(isBeingShown: .constant(true))
    }

}
