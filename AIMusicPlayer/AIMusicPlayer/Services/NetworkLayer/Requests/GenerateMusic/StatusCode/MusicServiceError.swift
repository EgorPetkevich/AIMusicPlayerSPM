//
//  MusicServiceError.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 23.12.25.
//

import Foundation

enum MusicServiceError: LocalizedError {
    case emptyResponse
    case apiFailed(String)
    case pollingTimeout
    case pollingTerminal(String)
    case invalidURL
    case audioLoadFailed(String)
    case coverLoadFailed(String)

    var errorDescription: String? {
        switch self {
        case .emptyResponse: return "Empty response from server."
        case .apiFailed(let msg): return msg
        case .pollingTimeout: return "Generation timed out. Please try again."
        case .pollingTerminal(let msg): return msg
        case .invalidURL: return "Invalid URL."
        case .audioLoadFailed(let msg): return "Audio download failed: \(msg)"
        case .coverLoadFailed(let msg): return "Cover download failed: \(msg)"
        }
    }
}
