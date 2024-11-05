import SwiftUI

struct EmailAppPickerView: View {

    @Binding var isBeingShown: Bool
    @Binding var didCopySupportAddress: Bool

    let subject: String
    let emailBody: String

    var body: some View {
        NavigationView {
            Form {
                Section("Apps de e-mail") {
                    Button("App Padrão") {
                        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                        let encodedBody = emailBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                        let mailToString = "mailto:\(Mailman.supportEmail)?subject=\(encodedSubject)&body=\(encodedBody)"
                        guard let mailToUrl = URL(string: mailToString) else {
                            return
                        }
                        UIApplication.shared.open(mailToUrl)
                        sendAnalytics(for: "default app")
                        self.isBeingShown = false
                    }
                    
                    if Mailman.hasGmail {
                        Button("Gmail") {
                            let mailToString = "\(Mailman.gmailMailToUrl)?to=\(Mailman.supportEmail)"
                            guard let mailToUrl = URL(string: mailToString) else {
                                return
                            }
                            UIApplication.shared.open(mailToUrl)
                            sendAnalytics(for: "Gmail")
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
                            sendAnalytics(for: "Outlook")
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
                            sendAnalytics(for: "Yahoo Mail")
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
                            sendAnalytics(for: "Spark")
                            self.isBeingShown = false
                        }
                    }
                }
                
                Section("Outras opções") {
                    Button("Copiar endereço de e-mail") {
                        UIPasteboard.general.string = Mailman.supportEmail
                        self.didCopySupportAddress = true
                        sendAnalytics(for: "copy address")
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
        .frame(
            minWidth: 320,
            idealWidth: 400,
            maxWidth: nil,
            minHeight: 150,
            idealHeight: 300,
            maxHeight: nil,
            alignment: .top
        )
    }

    private func sendAnalytics(for option: String) {
        Analytics().send(
            originatingScreen: "EmailAppPickerView",
            action: "didPickEmailOption(\(option))"
        )
    }
}

#Preview {
    EmailAppPickerView(
        isBeingShown: .constant(true),
        didCopySupportAddress: .constant(false),
        subject: "",
        emailBody: ""
    )
}
