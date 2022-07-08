import SwiftUI

struct ToastView: View {

    @State var text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color.white)
                .frame(height: 50)
                .shadow(color: .gray, radius: 2, y: 2)
            
            HStack {
                Text(text)
                    .foregroundColor(.black)
                    .font(.callout)
                    .bold()
                
                Spacer()
            }
            .padding(.leading, 20)
        }
    }

}

struct ToastView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            ToastView(text: "🤑 Econoboys")
                .padding(.horizontal)
        }
        .previewLayout(.fixed(width: 414, height: 100))
    }

}
