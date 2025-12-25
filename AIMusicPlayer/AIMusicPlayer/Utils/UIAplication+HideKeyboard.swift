//
//  UIAplication+HideKeyboard.swift
//  OfflineMusicPlayerProject
//
//  Created by George Popkich on 3.12.25.
//

import UIKit

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
