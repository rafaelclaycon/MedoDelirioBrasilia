import SwiftUI

struct ToastView: View {

    let icon: String
    let iconColor: Color
    let text: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 50, style: .continuous)
                .fill(Color.white)
                .frame(height: 50)
                .shadow(color: .gray, radius: 2, y: 2)
            
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(Font.system(size: 20, weight: .bold))
                    .foregroundColor(iconColor)
                
                Text(text)
                    .foregroundColor(.black)
                    .font(.callout)
                    .bold()
                
                Spacer(minLength: 0)
            }
            .padding(.leading, 20)
        }
    }

}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ToastView(
                icon: "checkmark",
                iconColor: .green,
                text: "Todos os dados atualizados."
            )

            ToastView(
                icon: "checkmark",
                iconColor: .green,
                text: "Conteúdo baixado com sucesso. Tente tocá-lo novamente."
            )

            ToastView(
                icon: "checkmark",
                iconColor: .green,
                text: "Sincronização concluída com sucesso."
            )

            ToastView(
                icon: "clock.fill",
                iconColor: .orange,
                text: "Aguarde mais um pouco para atualizar novamente."
            )

            ToastView(
                icon: "checkmark",
                iconColor: .green,
                text: "Som adicionado à pasta 🤑 Econoboys."
            )
            .padding(.horizontal)
        }
        .previewLayout(.fixed(width: 414, height: 100))
    }
}
