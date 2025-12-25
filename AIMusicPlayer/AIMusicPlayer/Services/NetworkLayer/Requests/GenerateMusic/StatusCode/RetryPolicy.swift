//
//  RetryPolicy.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 23.12.25.
//

import Foundation

struct RetryPolicy {
    let maxRetries: Int
    let initialDelay: TimeInterval
    let multiplier: Double
    let maxDelay: TimeInterval

    static let `default` = RetryPolicy(
        maxRetries: 2,
        initialDelay: 0.7,
        multiplier: 2.0,
        maxDelay: 5.0
    )

    func delay(for attempt: Int) -> TimeInterval {
        let d = initialDelay * pow(multiplier, Double(attempt))
        return min(d, maxDelay)
    }
}
