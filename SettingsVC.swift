import UIKit
import FirebaseAuth

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        // Display an alert asking if the user is sure they want to sign out
        showSignOutConfirmationAlert()
    }

    func showSignOutConfirmationAlert() {
        let alertController = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)

        // Yes action
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] (_) in
            guard let self = self else { return }

            do {
                // Sign the user out
                try Auth.auth().signOut()

                // Pop to the LoginVC in the navigation stack
                self.navigationController?.popToRootViewController(animated: true)

            } catch {
                // Handle sign-out error
                print("Sign-out error: \(error.localizedDescription)")
            }
        }))

        // No action
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}
