import SwiftUI

struct NotificationsSymbol: View {

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.gray)
                .frame(width: 280, height: 84)
                .opacity(0.3)
            
            // App icon
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .frame(width: 54, height: 54)
                .padding(.trailing, 195)
            
            // "Text"
            VStack(alignment: .leading, spacing: 15) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white)
                    .frame(width: 170, height: 13)
                
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white)
                    .frame(width: 120, height: 13)
            }
            .padding(.leading, 65)
            
            // Check mark
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 32, height: 32)
                
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 34)
                    .foregroundColor(.green)
            }
            .padding(.bottom, 80)
            .padding(.trailing, 265)
        }
    }

}

struct NotificationsSymbol_Previews: PreviewProvider {

    static var previews: some View {
        NotificationsSymbol()
    }

}
