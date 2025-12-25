//
//  AnalyticsEvent.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 24.12.25.
//

import Foundation

enum AnalyticsEvent {

    // MARK: - App lifecycle
    case appLaunched(isFirstLaunch: Bool)

    // MARK: - Generate flow
    case generateTapped(model: GenerateMusicModel)
    case generateNetworkFailed(code: Int?, message: String)
    case generateNetworkSucceeded(trackId: String)
    case loadTrackFailed(trackId: String, message: String)
    case loadTrackSucceeded(trackId: String)

    // MARK: - Player flow
    case playbackStart(track: TrackModel, source: PlaybackSource)

    enum PlaybackSource: String {
        case list
        case player
        case lockscreen
        case unknown
    }

    var name: String {
        switch self {
        case .appLaunched: return "app_launched"
        case .generateTapped: return "generate_tapped"
        case .generateNetworkFailed: return "generate_network_failed"
        case .generateNetworkSucceeded: return "generate_network_succeeded"
        case .loadTrackFailed: return "generate_load_failed"
        case .loadTrackSucceeded: return "generate_load_succeeded"
        case .playbackStart: return "playback_start"
        }
    }

    var parameters: [String: Any]? {
        switch self {

        case .appLaunched(let isFirstLaunch):
            return ["first_launch": isFirstLaunch]

        case .generateTapped(let model):
            return [
                "screen": "generate",
                "title_len": model.title.count,
                "prompt_len": model.prompt.count,
                "style": model.style,
                "model": model.model.rawValue
            ]

        case .generateNetworkFailed(let code, let message):
            return [
                "screen": "generate",
                "error_code": code ?? -1,
                "error": message.safeAnalyticsString()
            ]

        case .generateNetworkSucceeded(let trackId):
            return ["screen": "generate", "track_id": trackId]

        case .loadTrackFailed(let trackId, let message):
            return [
                "screen": "generate",
                "track_id": trackId,
                "error": message.safeAnalyticsString()
            ]

        case .loadTrackSucceeded(let trackId):
            return ["screen": "generate", "track_id": trackId]

        case .playbackStart(let track, let source):
            return [
                "track_id": track.id,
                "title_len": track.title.count,
                "source": source.rawValue
            ]
        }
    }
}
