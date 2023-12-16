import UIKit
import FirebaseAuth

class SignUpVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var showPasswordButton: UIButton!

    var isPasswordVisible: Bool = false {
        didSet {
            passwordTextField.isSecureTextEntry = !isPasswordVisible
            confirmPasswordTextField.isSecureTextEntry = !isPasswordVisible
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the password toggle
        setupPasswordToggle()
        
        // Set isEnabled for text fields
        emailTextField.isEnabled = true
        passwordTextField.isEnabled = true
        confirmPasswordTextField.isEnabled = true

        // Set the delegate for text fields
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self

        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func setupPasswordToggle() {
        // Set the initial state of the password visibility
        isPasswordVisible = false
        showPasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
    }

    @IBAction func showPasswordButtonTapped(_ sender: UIButton) {
        // Toggle the password visibility
        isPasswordVisible.toggle()

        // Update the image of the showPasswordButton based on the visibility state
        let imageName = isPasswordVisible ? "eye" : "eye.slash"
        showPasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text
        else {
            // Handle empty fields
            return
        }

        // Check if passwords match
        guard password == confirmPassword else {
            // Handle password mismatch
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }

            if let error = error {
                // Handle signup error
                self.showSignupErrorAlert(error: error)
                print("Signup error: \(error.localizedDescription)")
            } else {
                // Signup successful
                self.showWelcomeMessage()
            }
        }
    }

    func showSignupErrorAlert(error: Error) {
        let alertController = UIAlertController(title: "Signup Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func showWelcomeMessage() {
        let alertController = UIAlertController(title: "Welcome to Pinned", message: "Thank you for signing up!", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] (_) in
            // Dismiss the alert and push the destination view controller
            alertController.dismiss(animated: true) {
                let destinationVC = self?.storyboard?.instantiateViewController(withIdentifier: "FirstOpeningVC") as! FirstOpeningVC
                self?.navigationController?.pushViewController(destinationVC, animated: true)
            }
        })

        present(alertController, animated: true, completion: nil)
    }
}
