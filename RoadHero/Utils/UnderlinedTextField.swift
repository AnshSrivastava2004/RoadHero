//
//  UnderlinedTextField.swift
//  RoadHero
//
//  Created by Ansh Srivastava on 06/11/25.
//

import UIKit

@IBDesignable
class UnderlinedTextField: UITextField {
    
    @IBInspectable var underlineColor: UIColor = .lightGray {
        didSet { setNeedsLayout() }
    }
    @IBInspectable var underlineHeight: CGFloat = 1 {
        didSet { setNeedsLayout() }
    }

    private let underline = CALayer()

    override func layoutSubviews() {
        super.layoutSubviews()
        
        borderStyle = .none
        
        underline.removeFromSuperlayer()
        
        underline.backgroundColor = underlineColor.cgColor
        underline.frame = CGRect(
            x: 0,
            y: frame.height - underlineHeight,
            width: frame.width,
            height: underlineHeight
        )
        layer.addSublayer(underline)
    }
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
