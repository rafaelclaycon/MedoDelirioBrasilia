import SwiftUI

struct DiagnosticsView: View {

    @State var showAlert = false
    @State var alertTitle = ""
    @State var installId = UIDevice.current.identifierForVendor?.uuidString ?? ""
    
    var body: some View {
        Form {
            Section {
                Button("Testar conexão com o servidor") {
                    networkRabbit.checkServerStatus { response in
                        alertTitle = response
                        showAlert = true
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(alertTitle), dismissButton: .default(Text("OK")))
                }
            }
            
            Section {
                HStack {
                    Text("ID da instalação")
                    
                    Spacer()
                    
                    Text(installId)
                        .font(.monospaced(.caption)())
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.gray)
                        .onTapGesture {
                            UIPasteboard.general.string = installId
                        }
                }
            } footer: {
                Text("Esse código identifica apenas a instalação do app e é renovado caso você o desinstale e instale novamente.")
            }
        }
        .navigationTitle("Diagnóstico")
        .navigationBarTitleDisplayMode(.inline)
    }

}

struct DiagnosticsView_Previews: PreviewProvider {

    static var previews: some View {
        DiagnosticsView()
    }

}
