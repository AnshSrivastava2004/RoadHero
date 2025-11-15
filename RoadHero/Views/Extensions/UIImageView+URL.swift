//
//  UIImageView+URL.swift
//  RoadHero
//
//  Created by Ansh Srivastava on 14/11/25.
//

import UIKit

public extension UIImageView {
    private static var urlHandle: UInt8 = 0
    var url: URL? {
        get {
            return objc_getAssociatedObject(self, &UIImageView.urlHandle) as? URL
        }
        set {
            objc_setAssociatedObject(self, &UIImageView.urlHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
