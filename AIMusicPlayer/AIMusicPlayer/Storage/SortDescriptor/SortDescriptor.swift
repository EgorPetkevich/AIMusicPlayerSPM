//
//  SortDescriptor.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import RealmSwift

extension SortDescriptor {
    static var createdAt: SortDescriptor {
        SortDescriptor(keyPath: "createdAt", ascending: false)
    }
}
