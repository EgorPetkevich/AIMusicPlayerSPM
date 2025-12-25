//
//  MusicStatusResponse.swift
//  AIMusicPlayer
//
//  Created by George Popkich on 22.12.25.
//

import Foundation

///{
///  "code": 200,
///  "msg": "All generated successfully.",
///  "data": {
///    "callbackType": "complete",
///    "task_id": "2fac****9f72",
///    "data": [
///      {
///        "id": "e231****-****-****-****-****8cadc7dc",
///        "audio_url": "https://example.cn/****.mp3",
///        "stream_audio_url": "https://example.cn/****",
///        "image_url": "https://example.cn/****.jpeg",
///        "prompt": "[Verse] Night city lights shining bright",
///        "model_name": "chirp-v3-5",
///        "title": "Iron Man",
///        "tags": "electrifying, rock",
///        "createTime": "2025-01-01 00:00:00",
///        "duration": 198.44
///      },
///      {
///        "id": "e231****-****-****-****-****8cadc7dc",
///        "audio_url": "https://example.cn/****.mp3",
///        "stream_audio_url": "https://example.cn/****",
///        "image_url": "https://example.cn/****.jpeg",
///        "prompt": "[Verse] Night city lights shining bright",
///        "model_name": "chirp-v3-5",
///        "title": "Iron Man",
///        "tags": "electrifying, rock",
///        "createTime": "2025-01-01 00:00:00",
///        "duration": 228.28
///      }
///    ]
///  }
///}

struct MusicStatusResponse: Decodable {
    let code: Int
    let msg: String
    let data: DataBlock

    struct DataBlock: Decodable {
        let taskId: String
        let response: ResponseBlock?

        struct ResponseBlock: Decodable {
            let status: String?
            let sunoData: [Track]?
        }
    }
    
    struct Track: Decodable, Identifiable {
        let id: String
        let audioUrl: String?
        let streamAudioUrl: String?
        let imageUrl: String?
        let prompt: String?
        let modelName: String?
        let title: String?
        let tags: String?
        let createTime: Int64?
        let duration: Double?
    }
}

extension MusicStatusResponse {
    var statusCode: MusicGenerationStatusCode? {
        MusicGenerationStatusCode(rawValue: code)
    }
}
