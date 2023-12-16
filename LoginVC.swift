import UIKit
import FirebaseAuth

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    @IBOutlet weak var showPasswordButton: UIButton!
    
    var isPasswordVisible: Bool = false {
        didSet {
            passwordTextField.isSecureTextEntry = !isPasswordVisible
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the remembered email, if available
        if let rememberedEmail = UserDefaults.standard.string(forKey: "rememberedEmail") {
            emailTextField.text = rememberedEmail
            rememberMeSwitch.isOn = true
        }
        
        setupPasswordToggle()
        
        // Set isEnabled for text fields
        emailTextField.isEnabled = true
        passwordTextField.isEnabled = true

        // Set the delegate for text fields
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
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
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty
        else {
            // Show an alert for empty credentials
            showLoginErrorAlert(message: "Please enter both email and password.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            
            if let error = error {
                // Handle login error
                self.showLoginErrorAlert(message: error.localizedDescription)
                print("Login error: \(error.localizedDescription)")
            } else {
                // Login successful
                // Save the email if "Remember Me" is enabled
                if self.rememberMeSwitch.isOn {
                    UserDefaults.standard.set(email, forKey: "rememberedEmail")
                } else {
                    // Clear the remembered email if "Remember Me" is disabled
                    UserDefaults.standard.removeObject(forKey: "rememberedEmail")
                }
                
                // Programmatically specify the destination view controller
                let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "FirstOpeningVC") as! FirstOpeningVC
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
    func showLoginErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
