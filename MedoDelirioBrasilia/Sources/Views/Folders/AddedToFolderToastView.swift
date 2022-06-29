import SwiftUI

struct AddedToFolderToastView: View {

    @State var folderName: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color.white)
                .frame(height: 50)
                .shadow(color: .gray, radius: 5, y: 1)
            
            HStack {
                Text("Som adicionado à pasta \"\(folderName)\".")
                    .foregroundColor(.black)
                    .font(.callout)
                    .bold()
                
                Spacer()
            }
            .padding(.leading, 20)
        }
    }

}

struct AddedToFolderToastView_Previews: PreviewProvider {

    static var previews: some View {
        AddedToFolderToastView(folderName: "🤑 Econoboys")
    }

}
