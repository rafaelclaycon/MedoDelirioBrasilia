import SwiftUI

struct EmailAppPickerView: View {

    @Binding var isBeingShown: Bool
    @Binding var didCopySupportAddress: Bool

    let subject: String
    let emailBody: String
    var showQuizView: Bool = false

    var body: some View {
        NavigationView {
            Form {
                if showQuizView {
                    Section {
                        Button("Responder questionário") {
                            OpenUtility.open(link: surveyLink)
                            self.isBeingShown = false
                        }
                        .foregroundColor(.blue)
                    } footer: {
                        Text("Leva no máximo 3 minutos e ajuda muito! ❤️")
                    }
                }

                Section("Apps de e-mail") {
                    Button("App Padrão") {
                        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                        let encodedBody = emailBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                        let mailToString = "mailto:\(Mailman.supportEmail)?subject=\(encodedSubject)&body=\(encodedBody)"
                        guard let mailToUrl = URL(string: mailToString) else {
                            return
                        }
                        UIApplication.shared.open(mailToUrl)
                        self.isBeingShown = false
                    }
                    
                    if Mailman.hasGmail {
                        Button("Gmail") {
                            let mailToString = "\(Mailman.gmailMailToUrl)?to=\(Mailman.supportEmail)"
                            guard let mailToUrl = URL(string: mailToString) else {
                                return
                            }
                            UIApplication.shared.open(mailToUrl)
                            self.isBeingShown = false
                        }
                    }
                    
                    if Mailman.hasOutlook {
                        Button("Outlook") {
                            let mailToString = "\(Mailman.outlookMailToUrl)?to=\(Mailman.supportEmail)"
                            guard let mailToUrl = URL(string: mailToString) else {
                                return
                            }
                            UIApplication.shared.open(mailToUrl)
                            self.isBeingShown = false
                        }
                    }
                    
                    if Mailman.hasYahooMail {
                        Button("Yahoo Mail") {
                            let mailToString = "\(Mailman.yahooMailToUrl)?to=\(Mailman.supportEmail)"
                            guard let mailToUrl = URL(string: mailToString) else {
                                return
                            }
                            UIApplication.shared.open(mailToUrl)
                            self.isBeingShown = false
                        }
                    }
                    
                    if Mailman.hasSpark {
                        Button("Spark") {
                            let mailToString = "\(Mailman.sparkMailToUrl)?supportEmail=\(Mailman.supportEmail)"
                            guard let mailToUrl = URL(string: mailToString) else {
                                return
                            }
                            UIApplication.shared.open(mailToUrl)
                            self.isBeingShown = false
                        }
                    }
                }
                
                Section("Outras opções") {
                    Button("Copiar endereço de e-mail") {
                        UIPasteboard.general.string = Mailman.supportEmail
                        self.didCopySupportAddress = true
                        self.isBeingShown = false
                    }
                }
            }
            .navigationTitle("Escolha uma opção")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                Button("Cancelar") {
                    self.isBeingShown = false
                }
            )
        }
        .frame(minWidth: 320, idealWidth: 400, maxWidth: nil, minHeight: 150, idealHeight: 300, maxHeight: nil, alignment: .top)
    }

}

struct EmailAppPickerView_Previews: PreviewProvider {

    static var previews: some View {
        EmailAppPickerView(isBeingShown: .constant(true), didCopySupportAddress: .constant(false), subject: "", emailBody: "")
    }

}
