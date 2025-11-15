import UIKit
import Supabase

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    private let authService = AuthService()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        confirmButton.layer.cornerRadius = 10.0
        addCustomBackButton()
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Error", message: "Please enter your email.")
            return
        }
        
        Task {
            do {
                try await authService.resetPassword(for: email)
                
                await MainActor.run {
                    self.showAlert(title: "Success", message: "Password reset link sent to \(email).")
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Error", message: "Failed to send reset link. Please check your email and try again.")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
