import SwiftUI

struct ToastView: View {

    @State var text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50, style: .continuous)
                .fill(Color.white)
                .frame(height: 50)
                .shadow(color: .gray, radius: 2, y: 2)
            
            HStack(spacing: 15) {
                Image(systemName: "checkmark")
                    .font(Font.system(size: 20, weight: .bold))
                    .foregroundColor(.green)
                
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
            ToastView(text: "Som adicionado à pasta 🤑 Econoboys.")
                .padding(.horizontal)
        }
        .previewLayout(.fixed(width: 414, height: 100))
    }

}
