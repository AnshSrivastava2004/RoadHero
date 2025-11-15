//
//  UIViewController+BackButton.swift
//  RoadHero
//
//  Created by Ansh Srivastava on 14/11/25.
//

import UIKit

public extension UIViewController {
    func addCustomBackButton() {
        let backButton = UIButton(type: .system)
        backButton.setTitle("< Back", for: .normal)
        backButton.setTitleColor(UIColor(hex: "#FFD25A"), for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        backButton.tintColor = UIColor(hex: "#FFD25A")
        backButton.alpha = 1.0 // fully visible initially
        backButton.addTarget(self, action: #selector(customBackPressed), for: .touchUpInside)
        
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        backButton.tag = 999
    }
    
    @objc func customBackPressed() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    func handleBackButtonVisibility(for scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        guard let backButton = view.viewWithTag(999) as? UIButton else { return }
        
        UIView.animate(withDuration: 0.25) {
            backButton.alpha = (offsetY > 50) ? 0.0 : 1.0
        }
    }
}
