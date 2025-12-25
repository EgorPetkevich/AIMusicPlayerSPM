//
//  String+safeAnalyticsString.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 24.12.25.
//

import Foundation

extension String {
    func safeAnalyticsString(max: Int = 120) -> String {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= max { return trimmed }
        let idx = trimmed.index(trimmed.startIndex, offsetBy: max)
        return String(trimmed[..<idx])
    }
}
