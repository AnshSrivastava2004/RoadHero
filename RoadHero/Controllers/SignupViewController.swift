import UIKit
import Supabase

class SignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var greetingLabel: UILabel!
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var textFieldStackView: UIStackView!
    @IBOutlet weak var accountLabel: UILabel!
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let authService = AuthService()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert("Please fill in all fields.")
            return
        }
        
        guard password == confirmPassword else {
            showAlert("Passwords do not match.")
            return
        }
                
        Task { @MainActor in
            do {
                try await authService.signUpAndSignIn(
                    email: email,
                    password: password,
                    name: name
                )
                
                self.switchToHome()
                
            } catch {
                self.showAlert("Error: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    private func switchToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
            homeVC.modalPresentationStyle = .fullScreen
            present(homeVC, animated: true)
        }
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Signup", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        signupButton.layer.cornerRadius = 10.0
    
        setupScrollView()
        reparentUIElements()
        setupTextFieldDelegates()
        addKeyboardObservers()
        addTapGestureToDismissKeyboard()
        addCustomBackButton()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        handleBackButtonVisibility(for: scrollView)
    }
        
    private func reparentUIElements() {
        // Create a new main stack view
        let mainStack = UIStackView()
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.spacing = 15
        
        mainStack.alignment = .center
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 70),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30)
        ])

        let labelStack = UIStackView()
        labelStack.axis = .vertical
        labelStack.alignment = .leading
        labelStack.spacing = -2
        
        greetingLabel?.removeFromSuperview()
        if let greetingLabel = greetingLabel {
            labelStack.addArrangedSubview(greetingLabel)
        }
        
        accountLabel?.removeFromSuperview()
        if let accountLabel = accountLabel {
            labelStack.addArrangedSubview(accountLabel)
        }
        mainStack.addArrangedSubview(labelStack)
        
        labelStack.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        
        
        textFieldStackView?.removeFromSuperview()
        if let textFieldStackView = textFieldStackView {
            mainStack.addArrangedSubview(textFieldStackView)
            
            textFieldStackView.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        }
        
        loginStackView?.removeFromSuperview()
        if let loginStackView = loginStackView {
            mainStack.addArrangedSubview(loginStackView)
        }
        
        signupButton?.removeFromSuperview()
        if let signupButton = signupButton {
            mainStack.addArrangedSubview(signupButton)
        }
    }
        
        private func setupTextFieldDelegates() {
            nameTextField.delegate = self
            emailTextField.delegate = self
            passwordTextField.delegate = self
            confirmPasswordTextField.delegate = self
        }
}

// MARK: - Keyboard Handling
extension SignupViewController {
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        // Reset the scroll view's insets
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}

// MARK: - Dismiss Keyboard & TextField Return
extension SignupViewController {
    
    func addTapGestureToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            textField.resignFirstResponder()
            signupButtonTapped(signupButton)
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
