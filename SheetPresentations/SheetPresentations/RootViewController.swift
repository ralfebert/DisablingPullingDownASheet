/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The root view controller of the app. Contains a label displaying text, and a button to present a sheet for editing the text.
*/

import UIKit

class RootViewController: UIViewController, EditViewControllerDelegate {
    
    // MARK: - Model
    
    var text = "Hello World!" {
        didSet {
            viewIfLoaded?.setNeedsLayout()
        }
    }
    
    // MARK: - View
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewWillLayoutSubviews() {
        
        // Ensure textView.text is up to date
        textView.text = text
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "Edit":
            
            // Get the presented navigationController and the editViewController it contains
            let navigationController = segue.destination as! UINavigationController
            let editViewController = navigationController.topViewController as! EditViewController
            
            // Set the editViewController to be the delegate of the presentationController for this presentation,
            // so that editViewController can respond to attempted dismissals
            navigationController.presentationController?.delegate = editViewController
            
            // Set ourself as the delegate of editViewController, so we can respond to editViewController cancelling or finishing
            editViewController.delegate = self
            
            // Pass our model to the editViewController
            editViewController.originalText = text
        default:
            break
        }
    }
    
    // MARK: - EditViewControllerDelegate
    
    func editViewControllerDidCancel(_ editViewController: EditViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func editViewControllerDidFinish(_ editViewController: EditViewController) {
        text = editViewController.editedText
        dismiss(animated: true, completion: nil)
    }
}
