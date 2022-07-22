import SwiftUI

struct EmailAppPickerView: View {

    @Binding var isBeingShown: Bool
    @State var subject: String
    @State var emailBody: String
    
    var body: some View {
        NavigationView {
            List {
                Button("Mail") {
                    let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    let encodedBody = emailBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    let mailToString = "mailto:\(Mailman.recipient)?subject=\(encodedSubject)&body=\(encodedBody)"
                    guard let mailToUrl = URL(string: mailToString) else {
                        return
                    }
                    UIApplication.shared.open(mailToUrl)
                    self.isBeingShown = false
                }
                
                if Mailman.hasGmail {
                    Button("Gmail") {
                        let mailToString = "\(Mailman.gmailMailToUrl)?to=\(Mailman.recipient)"
                        guard let mailToUrl = URL(string: mailToString) else {
                            return
                        }
                        UIApplication.shared.open(mailToUrl)
                        self.isBeingShown = false
                    }
                }
                
                if Mailman.hasOutlook {
                    Button("Outlook") {
                        let mailToString = "\(Mailman.outlookMailToUrl)?to=\(Mailman.recipient)"
                        guard let mailToUrl = URL(string: mailToString) else {
                            return
                        }
                        UIApplication.shared.open(mailToUrl)
                        self.isBeingShown = false
                    }
                }
                
                if Mailman.hasYahooMail {
                    Button("Yahoo Mail") {
                        let mailToString = "\(Mailman.yahooMailToUrl)?to=\(Mailman.recipient)"
                        guard let mailToUrl = URL(string: mailToString) else {
                            return
                        }
                        UIApplication.shared.open(mailToUrl)
                        self.isBeingShown = false
                    }
                }
                
                if Mailman.hasSpark {
                    Button("Spark") {
                        let mailToString = "\(Mailman.sparkMailToUrl)?recipient=\(Mailman.recipient)"
                        guard let mailToUrl = URL(string: mailToString) else {
                            return
                        }
                        UIApplication.shared.open(mailToUrl)
                        self.isBeingShown = false
                    }
                }
            }
            .navigationTitle(Shared.pickAMailApp)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                Button("Cancelar") {
                    self.isBeingShown = false
                }
            )
        }
    }

}

struct EmailAppPickerView_Previews: PreviewProvider {

    static var previews: some View {
        EmailAppPickerView(isBeingShown: .constant(true), subject: "", emailBody: "")
    }

}
