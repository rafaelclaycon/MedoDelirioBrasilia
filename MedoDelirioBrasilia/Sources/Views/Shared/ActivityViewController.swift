import UIKit
import SwiftUI

#if os(iOS)
struct ActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var completionWithItemsHandler: UIActivityViewController.CompletionWithItemsHandler?
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.completionWithItemsHandler = completionWithItemsHandler
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}

}
#endif
