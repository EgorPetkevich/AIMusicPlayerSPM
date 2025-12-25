//
//  MusicGenerationStatusCode.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import Foundation

enum MusicGenerationStatusCode: Int {
    case success = 200
    case validationError = 400
    case rateLimited = 408
    case conflict = 413
    case serverError = 500
    case generationFailed = 501
    case refundedFailure = 531

    var isTerminal: Bool {
        switch self {
        case .success,
             .validationError,
             .conflict,
             .generationFailed,
             .refundedFailure:
            return true
        default:
            return false
        }
    }

    var userMessage: String {
        switch self {
        case .success:
            return "Music generated successfully."
        case .validationError:
            return "Lyrics contain copyrighted material."
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .conflict:
            return "Uploaded audio matches an existing work."
        case .serverError:
            return "Server error. Please try again."
        case .generationFailed:
            return "Audio generation failed."
        case .refundedFailure:
            return "Generation failed. Your credits have been refunded."
        }
    }
}
