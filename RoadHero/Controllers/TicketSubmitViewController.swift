import UIKit
import CoreLocation

protocol TicketSubmitViewControllerDelegate: AnyObject {
    func didTapRetake(from controller: TicketSubmitViewController)
    func didTapSubmit(from controller: TicketSubmitViewController, image: UIImage, location: CLLocation?, description: String)
}

class TicketSubmitViewController: UIViewController, UITextFieldDelegate, LocationServiceDelegate {

    public let capturedImage: UIImage
    public weak var delegate: TicketSubmitViewControllerDelegate?

    private let locationService = LocationService()
    private var currentLocation: CLLocation?

    private let imageView = UIImageView()
    private let locationLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let descriptionTextField = UITextField()
    private let submitButton = UIButton(type: .system)
    private let retakeButton = UIButton(type: .system)
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var activeTextField: UITextField?

    init(image: UIImage) {
        self.capturedImage = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupUI()
        setupKeyboardDismiss()
        
        descriptionTextField.delegate = self
        addKeyboardObservers()
        
        setupLocation()
    }
    
    deinit {
        removeKeyboardObservers()
        locationService.stopUpdatingLocation()
    }

    // 4. Update setupLocation to use the service
    private func setupLocation() {
        locationService.delegate = self
        
        if locationService.authorizationStatus == .notDetermined {
            locationService.requestAuthorization()
        } else {
            locationService.startUpdatingLocation()
        }
    }
    
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func setupUI() {
        view.backgroundColor = .black
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = capturedImage

        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = .systemFont(ofSize: 16)
        locationLabel.textColor = .systemGray
        locationLabel.text = "Fetching location..."
        locationLabel.textAlignment = .center

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .systemGray
        activityIndicator.startAnimating()

        descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextField.placeholder = "Enter description..."
        descriptionTextField.font = .systemFont(ofSize: 16)
        descriptionTextField.textColor = .white
        descriptionTextField.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        descriptionTextField.layer.cornerRadius = 8
        descriptionTextField.tintColor = .systemYellow
        descriptionTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        descriptionTextField.leftViewMode = .always
        descriptionTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        descriptionTextField.rightViewMode = .always

        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("Submit", for: .normal)
        submitButton.backgroundColor = .systemYellow
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)

        retakeButton.translatesAutoresizingMaskIntoConstraints = false
        retakeButton.setTitle("Retake", for: .normal)
        retakeButton.backgroundColor = .darkGray
        retakeButton.setTitleColor(.white, for: .normal)
        retakeButton.layer.cornerRadius = 8
        retakeButton.titleLabel?.font = .systemFont(ofSize: 18)
        retakeButton.addTarget(self, action: #selector(didTapRetake), for: .touchUpInside)

        let locationStack = UIStackView(arrangedSubviews: [locationLabel, activityIndicator])
        locationStack.spacing = 8
        locationStack.axis = .horizontal
        
        let buttonStack = UIStackView(arrangedSubviews: [retakeButton, submitButton])
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually
        buttonStack.axis = .horizontal

        let mainStack = UIStackView(arrangedSubviews: [imageView, locationStack, descriptionTextField, buttonStack])
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 20)
        
        mainStack.setCustomSpacing(10, after: locationStack)

        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            buttonStack.heightAnchor.constraint(equalToConstant: 50),
            descriptionTextField.heightAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.55)
        ])
    }
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func didTapSubmit() {
        guard let description = descriptionTextField.text, !description.isEmpty else {
            let alert = UIAlertController(title: "Missing Description", message: "Please enter a description for the issue.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        submitButton.isEnabled = false
        
        delegate?.didTapSubmit(from: self, image: capturedImage, location: currentLocation, description: description)
    }
    
    @objc private func didTapRetake() {
        delegate?.didTapRetake(from: self)
    }

    // MARK: - LocationServiceDelegate
    func didUpdateLocation(_ location: CLLocation) {
        currentLocation = location
        locationLabel.text = String(format: "Lat: %.6f, Lon: %.6f",
                                      location.coordinate.latitude,
                                      location.coordinate.longitude)
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        locationService.stopUpdatingLocation()
    }
    
    func didFailWithError(_ error: Error) {
        locationLabel.text = "Could not get location."
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func authorizationDidChange(to status: CLAuthorizationStatus) {
        if status == .denied {
            locationLabel.text = "Location access denied."
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationService.startUpdatingLocation()
        }
    }

    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Keyboard Handling
extension TicketSubmitViewController {
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        if let activeTextField = self.activeTextField {
            let rect = activeTextField.convert(activeTextField.bounds, to: self.scrollView)
            self.scrollView.scrollRectToVisible(rect, animated: true)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}
