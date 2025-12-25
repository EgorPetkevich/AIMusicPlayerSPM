//
//  UIApplication+firstKeyWindowRootVC.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 24.12.25.
//

import UIKit

extension UIApplication {
    var firstKeyWindowRootVC: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
