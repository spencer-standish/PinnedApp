import UIKit
import FirebaseAuth

class ForgotPasswordVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set isEnabled for text fields
        emailTextField.isEnabled = true

        // Set the delegate for text fields
        emailTextField.delegate = self

        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text else {
            // Handle empty field
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                // Handle reset password error
                print("Reset password error: \(error.localizedDescription)")
            } else {
                // Reset password email sent successfully
                print("Reset password email sent successfully")
            }
        }
    }
}
