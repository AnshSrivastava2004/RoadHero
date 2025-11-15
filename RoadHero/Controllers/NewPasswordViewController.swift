import UIKit
import Supabase

class NewPasswordViewController: UIViewController {
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    
    private let authService = AuthService()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        updateButton.layer.cornerRadius = 10
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        guard let newPassword = newPasswordField.text,
            let confirmPassword = confirmPasswordField.text,
            newPassword == confirmPassword else {
            showAlert(title: "Error", message: "Passwords do not match.")
            return
        }
        
        Task {
            do {
                try await authService.updatePassword(newPassword)
                
                await MainActor.run {
                    self.showAlert(title: "Success", message: "Your password has been reset. Please log in with your new password.") {
                        self.dismiss(animated: true) {}
                    }
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Error", message: "Failed to reset password.")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}
