/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view controller for editing saved text. Allows cancellation and saving with standard bar button items, as well as with the pull to dismiss gesture.
*/

import UIKit

protocol EditViewControllerDelegate: class {
    
    func editViewControllerDidCancel(_ editViewController: EditViewController)
    func editViewControllerDidFinish(_ editViewController: EditViewController)
}

class EditViewController: UIViewController, UITextViewDelegate, UIAdaptivePresentationControllerDelegate {
    
    // MARK: - Model
    
    var originalText = "" {
        didSet {
            editedText = originalText
        }
    }
    
    var editedText = "" {
        didSet {
            viewIfLoaded?.setNeedsLayout()
        }
    }
    
    var hasChanges: Bool {
        return originalText != editedText
    }
    
    // MARK: - Delegate
    
    weak var delegate: EditViewControllerDelegate?
    
    func sendDidCancel() {
        delegate?.editViewControllerDidCancel(self)
    }
    
    func sendDidFinish() {
        delegate?.editViewControllerDidFinish(self)
    }
    
    // MARK: - View
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // For user convenience, present the keyboard as soon as we begin appearing
        textView.becomeFirstResponder()
    }
    
    override func viewWillLayoutSubviews() {
        
        // Ensure textView.text is up to date
        textView.text = editedText
        
        // If our model has unsaved changes, prevent pull to dismiss and enable the save button
        let hasChanges = self.hasChanges
        isModalInPresentation = hasChanges
        saveButton.isEnabled = hasChanges
    }
    
    // MARK: - Events
    
    func textViewDidChange(_ textView: UITextView) {
        editedText = textView.text
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        if hasChanges {
            
            // The user tapped Cancel with unsaved changes
            // Confirm that they really mean to cancel
            confirmCancel(showingSave: false)
            
        } else {
            
            // No unsaved changes, so dismiss immediately
            sendDidCancel()
        }
    }
    
    @IBAction func save(_ sender: Any) {
        sendDidFinish()
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        
        // The user pulled down with unsaved changes
        // Clarify the user's intent by asking whether they intended to cancel or save
        confirmCancel(showingSave: true)
    }
    
    // MARK: - Cancellation Confirmation
    
    func confirmCancel(showingSave: Bool) {
        
        // Present an action sheet, which in a regular width environment appears as a popover
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Only ask if the user intended to save if they attempted to pull to dismiss, not if they tap Cancel
        if showingSave {
            alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
                self.delegate?.editViewControllerDidFinish(self)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive) { _ in
            self.delegate?.editViewControllerDidCancel(self)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // The popover should point at the Cancel button
        alert.popoverPresentationController?.barButtonItem = cancelButton
        
        present(alert, animated: true, completion: nil)
    }
}
