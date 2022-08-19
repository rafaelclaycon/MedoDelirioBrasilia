import SwiftUI

struct SharingViewController: UIViewControllerRepresentable {

    @Binding var isPresenting: Bool
    
    var content: () -> UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresenting {
            uiViewController.present(content(), animated: true, completion: nil)
        }
    }

}
