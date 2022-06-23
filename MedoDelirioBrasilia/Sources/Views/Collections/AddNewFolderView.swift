import SwiftUI

struct AddNewFolderView: View {

    @Binding var isBeingShown: Bool
    @State var symbol: String = ""
    @State var folderName: String = ""
    @State var backgroundColor: Color = .pastelBabyBlue
    
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
            .navigationTitle("Nova Pasta")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                Button(action: {
                    self.isBeingShown = false
                }) {
                    Text("Cancelar")
                }
            , trailing:
                Button(action: {
                    try? database.insert(userFolder: UserFolder(symbol: symbol, title: folderName, backgroundColor: backgroundColor.name ?? .empty))
                    self.isBeingShown = false
                }) {
                    Text("Criar")
                        .bold()
                }
            )
        }
    }

}

struct AddNewFolderView_Previews: PreviewProvider {

    static var previews: some View {
        AddNewFolderView(isBeingShown: .constant(true))
    }

}
