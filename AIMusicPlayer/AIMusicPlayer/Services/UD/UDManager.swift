//
//  UDManager.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 24.12.25.
//

import Foundation

final class UDManager {
    
    private static var ud: UserDefaults = .standard
    
    private init() {}
    
    static func set(_ key: AppStorageKeys, value: Bool) {
        ud.set(value, forKey: key.rawValue)
    }
    
    static func get(_ key: AppStorageKeys) -> Bool {
        ud.bool(forKey: key.rawValue)
    }
    
}
