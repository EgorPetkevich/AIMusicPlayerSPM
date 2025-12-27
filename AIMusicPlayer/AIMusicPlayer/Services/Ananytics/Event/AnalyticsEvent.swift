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

    // MARK: - Ads
    case adRequest(format: AdFormat, placement: AdPlacement)
    case adLoaded(format: AdFormat, placement: AdPlacement)
    case adLoadFailed(format: AdFormat, placement: AdPlacement, error: String)
    case adShown(format: AdFormat, placement: AdPlacement)
    case adShowFailed(format: AdFormat, placement: AdPlacement, error: String)
    case adDismissed(format: AdFormat, placement: AdPlacement)

    enum PlaybackSource: String { case list, player, lockscreen, unknown }

    enum AdFormat: String { case app_open, interstitial, native }
    enum AdPlacement: String { case app_open_resume, track_loaded_interstitial, generate_native }

    var name: String {
        switch self {
        case .appLaunched: return "app_launched"
        case .generateTapped: return "generate_tapped"
        case .generateNetworkFailed: return "generate_network_failed"
        case .generateNetworkSucceeded: return "generate_network_succeeded"
        case .loadTrackFailed: return "generate_load_failed"
        case .loadTrackSucceeded: return "generate_load_succeeded"
        case .playbackStart: return "playback_start"

        // Ads
        case .adRequest: return "ad_request"
        case .adLoaded: return "ad_loaded"
        case .adLoadFailed: return "ad_load_failed"
        case .adShown: return "ad_shown"
        case .adShowFailed: return "ad_show_failed"
        case .adDismissed: return "ad_dismissed"
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

        // Ads
        case .adRequest(let format, let placement),
             .adLoaded(let format, let placement),
             .adShown(let format, let placement),
             .adDismissed(let format, let placement):
            return [
                "ad_format": format.rawValue,
                "placement": placement.rawValue
            ]

        case .adLoadFailed(let format, let placement, let error),
             .adShowFailed(let format, let placement, let error):
            return [
                "ad_format": format.rawValue,
                "placement": placement.rawValue,
                "error": error.safeAnalyticsString()
            ]
        }
    }
}
