import SwiftUI

struct DiagnosticsView: View {

    @State var showAlert = false
    @State var alertTitle = ""
    
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
