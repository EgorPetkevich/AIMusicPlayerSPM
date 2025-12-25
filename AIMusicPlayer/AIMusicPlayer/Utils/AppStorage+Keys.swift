//
//  AppStorage+Keys.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 24.12.25.
//

import SwiftUI

enum AppStorageKeys: String {
    case didLaunchBefore
}

extension AppStorage where Value == Bool {
    
    init(
        wrappedValue: Bool,
        _ key: AppStorageKeys,
        store: UserDefaults? = nil
    ) {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
    
}


