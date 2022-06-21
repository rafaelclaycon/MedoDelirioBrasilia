import SwiftUI

struct AddNewFolderView: View {

    @Binding var isBeingShown: Bool
    @State var symbol: String = ""
    @State var folderName: String = ""
    
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
        VStack {
            HStack {
                Button(action: {
                    self.isBeingShown = false
                }) {
                    Text("Cancelar")
                }
                
                Spacer()
                
                Button(action: {
                    self.isBeingShown = false
                }) {
                    Text("OK")
                        .bold()
                }
            }
            .padding()
            
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.pastelBabyBlue)
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
            .padding()
            
            Spacer()
            
            ScrollView(.horizontal, showsIndicators: true) {
                LazyHGrid(rows: rows, spacing: 14) {
                    ForEach(colors) { folderColor in
                        Circle()
                            .fill(folderColor.color)
                            .frame(width: 40, height: 40)
                    }
                }
                .frame(height: 70)
            }
        }
    }

}

struct AddNewFolderView_Previews: PreviewProvider {

    static var previews: some View {
        AddNewFolderView(isBeingShown: .constant(true))
    }

}
