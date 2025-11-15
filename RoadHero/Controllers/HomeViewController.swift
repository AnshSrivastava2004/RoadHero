import UIKit
import CoreLocation
import Supabase

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TicketSubmitViewControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var activeCountLabel: UILabel!
    @IBOutlet weak var resolvedCountLabel: UILabel!
    @IBOutlet weak var greetingLabel: UILabel!
    
    @IBOutlet weak var resolvedView: UIView!
    @IBOutlet weak var activeView: UIView!
    
    // MARK: - Models
    private let ticketService = TicketService()
    private let userService = UserService()
    
    // MARK: - Supabase
    private let supabase = SupabaseManager.shared.client

    // MARK: - Theme
    private let backgroundColor = UIColor.black
    private let accentColor = UIColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = backgroundColor

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        resolvedView.layer.cornerRadius = 15.0
        resolvedView.clipsToBounds = true
        activeView.layer.cornerRadius = 15.0
        activeView.clipsToBounds = true
        cameraButton.layer.cornerRadius = 15.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchUserData()
    }
    
    // MARK: - Logout
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        Task {
                do {
                    try await SupabaseManager.shared.client.auth.signOut()

                    SessionManager.shared.clearSession()
                    UserDefaults.standard.removeObject(forKey: "supabaseSession")
                    
                    print("Logged out successfully.")

                    DispatchQueue.main.async {
                        self.navigateToLogin()
                    }
                } catch {
                    print("Failed to log out: \(error)")
                }
            }
    }
    
    private func navigateToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true)
    }

    // MARK: - Fetch User Counts
    private func fetchUserData() {
        Task {
            do {
                // 1. Get the user (or redirect)
                guard let user = SessionManager.shared.user else {
                    print("No user found, redirecting to login.")
                    await MainActor.run { self.navigateToLogin() }
                    return
                }

                // 2. Fetch name and counts in parallel
                async let userName = userService.fetchUserName(for: user)
                async let counts = ticketService.fetchTicketCounts(for: user)
                
                // 3. Await the results
                let (fetchedName, (activeCount, resolvedCount)) = try await (userName, counts)

                // 4. Update UI
                await MainActor.run {
                    self.greetingLabel.text = "Hi, \(fetchedName)!"
                    self.activeCountLabel.text = "\(activeCount)"
                    self.resolvedCountLabel.text = "\(resolvedCount)"
                }
                
                print("Successfully fetched name and ticket counts for \(fetchedName)")

            } catch {
                print("Error fetching user data: \(error)")
                await MainActor.run {
                    self.greetingLabel.text = "Hi, User!"
                    self.activeCountLabel.text = "0"
                    self.resolvedCountLabel.text = "0"
                }
            }
        }
    }


    // MARK: - Camera
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        didTapCameraButton()
    }

    @objc private func didTapCameraButton() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "Camera Not Available", message: "This device does not have a camera.")
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }

        picker.dismiss(animated: true) {
            self.showTicketSubmit(with: image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    // MARK: - Ticket Submit
    private func showTicketSubmit(with image: UIImage) {
        let submitVC = TicketSubmitViewController(image: image)
        submitVC.delegate = self
        submitVC.modalPresentationStyle = .fullScreen
        present(submitVC, animated: true)
    }

    func didTapRetake(from controller: TicketSubmitViewController) {
        controller.dismiss(animated: true) { [weak self] in
            self?.didTapCameraButton()
        }
    }

    func didTapSubmit(from controller: TicketSubmitViewController, image: UIImage, location: CLLocation?, description: String) {
            
        controller.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            self.showLoadingOverlay(text: "Submitting Ticket...")
            
            guard let user = SessionManager.shared.user else {
                self.hideLoadingOverlay()
                self.showAlert(title: "Error", message: "You are no longer logged in.")
                return
            }
            
            Task {
                do {
                    try await self.ticketService.submitPothole(
                        image: image,
                        location: location,
                        description: description,
                        user: user
                    )
                    
                    await MainActor.run {
                        self.hideLoadingOverlay()
                        self.showAlert(title: "Success", message: "Ticket submitted successfully.")
                        self.fetchUserData()
                    }
                } catch {
                    await MainActor.run {
                        self.hideLoadingOverlay()
                        self.showAlert(title: "Submission Failed", message: error.localizedDescription)
                    }
                }
            }
        }
    }

    // MARK: - UI Helpers
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - Loading Overlay
    private var loadingOverlay: LoadingOverlay?
    
    func presentSubmitController(image: UIImage) {
        let submitVC = TicketSubmitViewController(image: image)
        submitVC.delegate = self
        submitVC.modalPresentationStyle = .fullScreen
        self.present(submitVC, animated: true)
    }
    
    private func showLoadingOverlay(text: String) {
        guard self.loadingOverlay == nil else { return }
        
        let overlay = LoadingOverlay(frame: self.view.bounds, text: text)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.addSubview(overlay)
        self.loadingOverlay = overlay
    }
        
    private func hideLoadingOverlay() {
        UIView.animate(withDuration: 0.2, animations: {
            self.loadingOverlay?.alpha = 0
        }) { _ in
            self.loadingOverlay?.removeFromSuperview()
            self.loadingOverlay = nil
        }
    }
}
