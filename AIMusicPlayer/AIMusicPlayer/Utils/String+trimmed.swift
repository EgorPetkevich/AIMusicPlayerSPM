//
//  String+trimmed.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import Foundation

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var nilIfEmpty: String? {
        trimmed.isEmpty ? nil : trimmed
    }
}
