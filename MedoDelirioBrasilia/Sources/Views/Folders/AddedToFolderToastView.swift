import SwiftUI

struct AddedToFolderToastView: View {

    @State var folderName: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color.white)
                .frame(height: 50)
                .shadow(color: .gray, radius: 2, y: 2)
            
            HStack {
                Text("Som adicionado à pasta \(folderName).")
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
        Group {
            AddedToFolderToastView(folderName: "🤑 Econoboys")
                .padding(.horizontal)
        }
        .previewLayout(.fixed(width: 414, height: 100))
    }

}
